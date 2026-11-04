import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { mkdir, mkdtemp, rm, symlink } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import test from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";

const install = join(homedir(), ".pi/agent/install");
const version = readFileSync(join(install, "current-version"), "utf8").trim();
const modules = join(install, "releases", version, "node_modules/@earendil-works");
const { createAgentSession, DefaultResourceLoader, ModelRuntime, SessionManager, SettingsManager } =
  await import(pathToFileURL(join(modules, "pi-coding-agent/dist/index.js")));
const { AssistantMessageEventStream } = await import(pathToFileURL(join(modules, "pi-ai/dist/index.js")));
const extensionPath = resolve(dirname(fileURLToPath(import.meta.url)), "../index.js");
const user = { role: "user", content: "Finish the existing task", timestamp: 1 };

function assistant(stopReason = "stop", content = [{ type: "text", text: "Finished" }]) {
  return {
    role: "assistant", content, api: "openai-completions", provider: "continue-test", model: "stub",
    usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0,
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 } },
    stopReason, timestamp: 2,
    ...(stopReason === "error" ? { errorMessage: "503 Service Unavailable" } : {}),
  };
}

async function fixture(t, messages = [], options = {}) {
  const directory = await mkdtemp(join(tmpdir(), "pi-continue-test-"));
  const manager = options.manager ?? (options.persistent
    ? SessionManager.create(directory, join(directory, "sessions"))
    : SessionManager.inMemory(directory));
  for (const message of messages) manager.appendMessage(structuredClone(message));
  const settingsManager = SettingsManager.inMemory({
    compaction: { enabled: false }, cacheWarming: "off",
    retry: { enabled: Boolean(options.retry), maxRetries: 1, baseDelayMs: 1, maxAgentDelayMs: 1 },
  });
  const modelRuntime = await ModelRuntime.create({
    authPath: join(directory, "auth.json"), modelsPath: null,
    modelsStorePath: join(directory, "models-cache.json"), refreshOnCreate: false, allowModelNetwork: false,
  });
  modelRuntime.registerProvider("continue-test", {
    api: "openai-completions", apiKey: "unused-test-key",
    models: [{ id: "stub", name: "Stub", baseUrl: "http://unused.invalid", reasoning: false,
      input: ["text"], contextWindow: 100000, maxTokens: 4096,
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 } }],
  });
  if (options.discover) {
    await mkdir(join(directory, "extensions"));
    await symlink(dirname(extensionPath), join(directory, "extensions/continue"));
  }
  const loader = new DefaultResourceLoader({
    cwd: manager.getCwd(), agentDir: directory, settingsManager,
    noExtensions: !options.discover, noSkills: true, noPromptTemplates: true, noThemes: true, noContextFiles: true,
    additionalExtensionPaths: !options.discover && existsSync(extensionPath) ? [extensionPath] : [],
  });
  await loader.reload();
  assert.deepEqual(loader.getExtensions().errors, []);
  const { session } = await createAgentSession({
    cwd: manager.getCwd(), agentDir: directory, sessionManager: manager, settingsManager,
    resourceLoader: loader, modelRuntime, model: modelRuntime.getModel("continue-test", "stub"),
    thinkingLevel: "off", tools: options.tools?.map((tool) => tool.name) ?? [],
    noTools: "all", customTools: options.tools,
  });
  const requests = [], notices = [], errors = [], events = [];
  let continueCalls = 0;
  const originalContinue = session.agent.continue.bind(session.agent);
  session.agent.continue = async () => { continueCalls++; return originalContinue(); };
  session.agent.streamFunction = (model, context, streamOptions) => {
    requests.push(structuredClone(context.messages));
    const stream = new AssistantMessageEventStream();
    const finish = (message) => {
      stream.push({ type: "start", partial: message });
      stream.push(message.stopReason === "error" || message.stopReason === "aborted"
        ? { type: "error", reason: message.stopReason, error: message }
        : { type: "done", reason: message.stopReason, message });
      stream.end(message);
    };
    if (options.hold) {
      options.opened?.();
      streamOptions.signal.addEventListener("abort", () => finish(assistant("aborted")), { once: true });
    } else {
      queueMicrotask(() => finish(options.responses?.[requests.length - 1] ?? assistant()));
    }
    return stream;
  };
  session.subscribe((event) => events.push(event));
  await session.bindExtensions({ mode: "rpc", uiContext: {
    notify: (message, level) => notices.push({ message, level }),
  }, onError: (error) => errors.push(error) });
  let closed = false;
  async function close() {
    if (closed) return;
    closed = true;
    await session.abort();
    await session.extensionRunner.emit({ type: "session_shutdown", reason: "quit" });
    session.dispose();
  }
  t.after(async () => { await close(); await rm(directory, { recursive: true, force: true }); });
  return { session, manager, requests, notices, errors, events, close,
    get continueCalls() { return continueCalls; } };
}

function requireCommand(f) {
  assert.ok(f.session.extensionRunner.getCommand("continue"), "/continue must be registered as a local command");
}

test("auto-discovers /continue from the global extensions directory", async (t) => {
  const f = await fixture(t, [user, assistant("aborted")], { discover: true });
  requireCommand(f);
  await f.session.prompt("/continue");
  assert.equal(f.continueCalls, 1);
  assert.deepEqual(f.requests[0].filter((m) => m.role !== "system"), [user]);
  assert.deepEqual(f.errors, []);
});

for (const reason of ["aborted", "error"]) {
  test(`continues a ${reason} response without injecting a message`, async (t) => {
    const interrupted = assistant(reason, [{ type: "text", text: "Partial answer" }]);
    const f = await fixture(t, [user, interrupted]);
    requireCommand(f);
    await f.session.prompt("/continue");
    assert.equal(f.continueCalls, 1);
    assert.deepEqual(f.requests[0].filter((m) => m.role !== "system"), [user]);
    const entries = f.manager.getEntries();
    assert.equal(entries.filter((e) => e.type === "message" && e.message.role === "user").length, 1);
    assert.equal(entries.filter((e) => e.type === "custom_message").length, 0);
    assert.ok(entries.some((e) => e.type === "message" && e.message.stopReason === reason));
    assert.equal(f.session.getLastAssistantText(), "Finished");
    assert.equal(f.session.isIdle, true);
    assert.equal(f.events.filter((e) => e.type === "agent_settled").length, 1);
    assert.deepEqual(f.errors, []);
  });
}

test("retains completed tool-call/result pairs when continuing", async (t) => {
  const toolCall = assistant("toolUse", [{ type: "toolCall", id: "call-1", name: "write", arguments: {} }]);
  const result = { role: "toolResult", toolCallId: "call-1", toolName: "write",
    content: [{ type: "text", text: "Already written" }], isError: false, timestamp: 3 };
  const f = await fixture(t, [user, toolCall, result, assistant("aborted")]);
  requireCommand(f);
  await f.session.prompt("/continue");
  assert.deepEqual(f.requests[0].filter((m) => m.role !== "system"), [user, toolCall, result]);
  assert.deepEqual(f.errors, []);
});

test("continues directly from an interrupted tool result", async (t) => {
  const call = assistant("toolUse", [{ type: "toolCall", id: "call-2", name: "bash", arguments: {} }]);
  const result = { role: "toolResult", toolCallId: "call-2", toolName: "bash",
    content: [{ type: "text", text: "Execution aborted" }], isError: true, timestamp: 3 };
  const f = await fixture(t, [user, call, result]);
  requireCommand(f);
  await f.session.prompt("/continue");
  assert.deepEqual(f.requests[0].filter((m) => m.role !== "system"), [user, call, result]);
  assert.equal(f.manager.getEntries().filter((e) => e.type === "context_edit").length, 0);
  assert.deepEqual(f.errors, []);
});

for (const [name, messages, command] of [
  ["empty session", [], "/continue"],
  ["completed answer", [user, assistant()], "/continue"],
  ["unexpected arguments", [user], "/continue unwanted text"],
]) {
  test(`does not alter an ${name} or send a request`, async (t) => {
    const f = await fixture(t, messages);
    requireCommand(f);
    const before = structuredClone(f.manager.getEntries());
    await f.session.prompt(command);
    assert.equal(f.continueCalls, 0);
    assert.equal(f.requests.length, 0);
    assert.deepEqual(f.manager.getEntries(), before);
    assert.ok(f.notices.length > 0);
    assert.equal(f.session.isIdle, true);
    assert.deepEqual(f.errors, []);
  });
}

test("rejects concurrent continuation and Escape can cancel the resumed run", async (t) => {
  let opened;
  const ready = new Promise((resolve) => { opened = resolve; });
  const options = { hold: true, opened };
  const f = await fixture(t, [user, assistant("aborted")], options);
  requireCommand(f);
  const running = f.session.prompt("/continue");
  await ready;
  assert.equal(f.session.isIdle, false);
  await f.session.prompt("/continue");
  assert.equal(f.requests.length, 1);
  assert.equal(f.continueCalls, 1);
  assert.ok(f.notices.some((n) => n.level === "warning"));
  await f.session.abort();
  await running;
  assert.equal(f.session.isIdle, true);
  assert.ok(f.events.some((e) => e.type === "agent_settled" && e.aborted));
  options.hold = false;
  await f.session.prompt("/continue");
  assert.equal(f.continueCalls, 2);
  assert.equal(f.requests.length, 2);
  assert.deepEqual(f.requests[1].filter((m) => m.role !== "system"), [user]);
  assert.equal(f.session.getLastAssistantText(), "Finished");
  assert.equal(f.session.isIdle, true);
  assert.deepEqual(f.errors, []);
});

test("resumed work can execute tools and finish without a new prompt", async (t) => {
  let executions = 0;
  const f = await fixture(t, [user, assistant("aborted")], {
    tools: [{ name: "finish_task", label: "Finish task", description: "Finish a local test task",
      parameters: { type: "object", properties: {}, additionalProperties: false },
      execute: async () => {
        executions++;
        return { content: [{ type: "text", text: "Task finished by the tool" }], details: {} };
      } }],
    responses: [assistant("toolUse", [{ type: "toolCall", id: "finish-step",
      name: "finish_task", arguments: {} }]), assistant()],
  });
  requireCommand(f);
  await f.session.prompt("/continue");
  assert.equal(executions, 1);
  assert.equal(f.continueCalls, 1);
  assert.equal(f.requests.length, 2);
  assert.ok(f.requests[1].some((m) => m.role === "toolResult" &&
    m.toolCallId === "finish-step" && m.content[0].text === "Task finished by the tool"));
  assert.equal(f.manager.getEntries().filter((e) => e.type === "message" && e.message.role === "user").length, 1);
  assert.equal(f.manager.getEntries().filter((e) => e.type === "custom_message").length, 0);
  assert.equal(f.session.getLastAssistantText(), "Finished");
  assert.equal(f.session.isIdle, true);
  assert.deepEqual(f.errors, []);
});

test("native retry recovers a connection error during continuation", async (t) => {
  const f = await fixture(t, [user, assistant("aborted")], {
    retry: true, responses: [assistant("error"), assistant()],
  });
  requireCommand(f);
  await f.session.prompt("/continue");
  assert.equal(f.continueCalls, 2);
  assert.equal(f.requests.length, 2);
  for (const request of f.requests) assert.deepEqual(request.filter((m) => m.role !== "system"), [user]);
  assert.ok(f.events.some((e) => e.type === "auto_retry_end" && e.success));
  assert.equal(f.session.isIdle, true);
  assert.deepEqual(f.errors, []);
});

test("/continue works after /reload without stacking runtime hooks", async (t) => {
  const f = await fixture(t, [user, assistant("aborted")]);
  requireCommand(f);
  await f.session.reload();
  requireCommand(f);
  await f.session.prompt("/continue");
  assert.equal(f.continueCalls, 1);
  assert.equal(f.requests.length, 1);
  assert.deepEqual(f.errors, []);
});

test("/continue works after reopening a saved interrupted session", async (t) => {
  const original = await fixture(t, [user, assistant("aborted")], { persistent: true });
  requireCommand(original);
  const sessionFile = original.manager.getSessionFile();
  assert.ok(existsSync(sessionFile));
  await original.close();
  const f = await fixture(t, [], { manager: SessionManager.open(sessionFile) });
  requireCommand(f);
  await f.session.prompt("/continue");
  assert.deepEqual(f.requests[0].filter((m) => m.role !== "system"), [user]);
  assert.equal(f.continueCalls, 1);
  assert.equal(f.manager.getEntries().filter((e) => e.type === "custom_message").length, 0);
  assert.deepEqual(f.errors, []);
});
