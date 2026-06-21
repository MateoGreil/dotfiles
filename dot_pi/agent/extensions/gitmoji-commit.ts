import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

const COMMIT_BOUNDARY = /(?:^|[\n;&|(])\s*git\s+commit(?![\w-])/;
const MESSAGE_ARG =
  /(?:^|\s)(?:--message(?:=|\s+)|-[a-zA-Z]*m(?:=\s*|\s+|(?=["'])))("([^"]*)"|'([^']*)'|(\S+))/;
const ENTRY = /^(.+?)\s+-\s+(:[a-z0-9_+-]+:)/;
const VARIATION = /\uFE0F/g;

type Gitmoji = { codes: Set<string>; emojis: Set<string>; reference: string };

let cached: Promise<Gitmoji> | null = null;

function parse(stdout: string): Gitmoji {
  const codes = new Set<string>();
  const emojis = new Set<string>();
  for (const line of stdout.split("\n")) {
    const entry = ENTRY.exec(line);
    if (entry === null) continue;
    emojis.add(entry[1].trim().replace(VARIATION, ""));
    codes.add(entry[2]);
  }
  return { codes, emojis, reference: stdout.trim() };
}

function gitmoji(): Promise<Gitmoji> {
  if (!cached) {
    cached = execFileAsync("gitmoji", ["-l"], { timeout: 5000 })
      .then(({ stdout }) => parse(stdout))
      .catch(() => ({
        codes: new Set<string>(),
        emojis: new Set<string>(),
        reference: "",
      }));
  }
  return cached;
}

function firstCommitSubject(command: string): string | null {
  const commit = COMMIT_BOUNDARY.exec(command);
  if (!commit) return null;
  const rest = command.slice(commit.index + commit[0].length);
  const message = MESSAGE_ARG.exec(rest);
  if (!message) return null;
  return message[2] ?? message[3] ?? message[4] ?? "";
}

function hasGitmojiPrefix(subject: string, { codes, emojis }: Gitmoji): boolean {
  const trimmed = subject.replace(/^\s+/, "");
  const code = /^(:[a-z0-9_+-]+:)/.exec(trimmed);
  if (code !== null) return codes.size === 0 || codes.has(code[1]);
  if (emojis.size === 0) return /^\p{Extended_Pictographic}/u.test(trimmed);
  const normalized = trimmed.replace(VARIATION, "");
  for (const emoji of emojis) {
    if (normalized.startsWith(emoji)) return true;
  }
  return false;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (!isToolCallEventType("bash", event)) return;
    const command = event.input.command;
    if (!command) return;

    const subject = firstCommitSubject(command);
    if (subject === null) return;

    const data = await gitmoji();
    if (hasGitmojiPrefix(subject, data)) return;

    return {
      block: true,
      reason:
        `This commit message must start with a gitmoji. Got: "${subject}".\n` +
        `Prefix the subject with one of these (the emoji or its :shortcode:), ` +
        `then retry, e.g. git commit -m "✨ ${subject}":\n\n` +
        (data.reference || "Run `gitmoji -l` to list the available gitmojis."),
    };
  });
}
