import { AgentSession } from "@earendil-works/pi-coding-agent";

const requiredMethods = [
  "_omitRecoveryAttempt",
  "_recordSelection",
  "_handlePostAgentRun",
  "_runBeforeSettleBoundary",
  "_finishCancelledRetry",
  "_flushPendingBashMessages",
  "_flushPendingCustomMessages",
  "_emitAgentSettled",
];

async function continueSession(session, failedAttempt) {
  if (failedAttempt) session._omitRecoveryAttempt(failedAttempt);
  session._isAgentRunActive = true;
  session._agentRunAbortRequested = false;
  session._failedResponse = undefined;
  try {
    session._recordSelection();
    do {
      await session.agent.continue();
      if (session._agentRunAbortRequested) break;
      if (await session._handlePostAgentRun()) continue;
      if (session._agentRunAbortRequested || !(await session._runBeforeSettleBoundary())) break;
    } while (!session._agentRunAbortRequested);
  } finally {
    if (session._agentRunAbortRequested) session._finishCancelledRetry();
    session._failedResponse = undefined;
    session._runSystemPromptOptions = undefined;
    session._flushPendingBashMessages();
    session._flushPendingCustomMessages();
    await session._emitAgentSettled();
  }
}

export default function (pi) {
  const sessions = new WeakMap();
  const originalBind = AgentSession.prototype._bindExtensionCore;
  const captureSession = typeof originalBind === "function"
    ? function (...args) {
      sessions.set(this.sessionManager, this);
      return originalBind.apply(this, args);
    }
    : undefined;
  if (captureSession) AgentSession.prototype._bindExtensionCore = captureSession;

  pi.on("session_shutdown", (_event, ctx) => {
    sessions.delete(ctx.sessionManager);
    if (captureSession && AgentSession.prototype._bindExtensionCore === captureSession) {
      AgentSession.prototype._bindExtensionCore = originalBind;
    }
  });

  pi.registerCommand("continue", {
    description: "Resume interrupted work without adding a message",
    handler: async (args, ctx) => {
      if (args.trim()) {
        ctx.ui.notify("Usage: /continue (without arguments).", "warning");
        return;
      }
      if (!ctx.isIdle()) {
        ctx.ui.notify("Interrupt the agent (esc) before /continue.", "warning");
        return;
      }
      const session = sessions.get(ctx.sessionManager);
      if (!session || requiredMethods.some((name) => typeof session[name] !== "function") ||
          typeof session.agent?.continue !== "function" ||
          typeof session._isAgentRunActive !== "boolean" ||
          typeof session._agentRunAbortRequested !== "boolean") {
        ctx.ui.notify("/continue is incompatible with this Pi version. Reload or restart Pi.", "error");
        return;
      }
      if (session.agent.state.isStreaming) {
        ctx.ui.notify("Interrupt the agent (esc) before /continue.", "warning");
        return;
      }
      if (!session.model) {
        ctx.ui.notify("Select a model before /continue.", "warning");
        return;
      }
      const last = session.messages.findLast((message) => message.role !== "system");
      const failedAttempt = last?.role === "assistant" &&
        (last.stopReason === "aborted" || last.stopReason === "error") ? last : undefined;
      if (!last || (failedAttempt && session.messages.every((message) =>
          message.role === "system" || message === failedAttempt))) {
        ctx.ui.notify("No unfinished request to continue.", "info");
        return;
      }
      if (last.role === "assistant" && !failedAttempt) {
        ctx.ui.notify("The last answer is complete; there is no interrupted response to resume.", "info");
        return;
      }
      try {
        await continueSession(session, failedAttempt);
      } catch (error) {
        ctx.ui.notify(`Unable to continue: ${error instanceof Error ? error.message : String(error)}`, "error");
      }
    },
  });
}
