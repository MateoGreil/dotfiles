import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

const COMMIT_BOUNDARY = /(?:^|[\n;&|(])\s*git\s+commit(?![\w-])/;
const MESSAGE_ARG =
  /(?:^|\s)(?:--message(?:=|\s+)|-[a-zA-Z]*m(?:=\s*|\s+|(?=["'])))("([^"]*)"|'([^']*)'|(\S+))/;
const SHORTCODE = /:[a-z0-9_+-]+:/g;

type Gitmoji = { codes: Set<string>; reference: string };

let cached: Promise<Gitmoji> | null = null;

function gitmoji(): Promise<Gitmoji> {
  if (!cached) {
    cached = execFileAsync("gitmoji", ["-l"], { timeout: 5000 })
      .then(({ stdout }) => ({
        codes: new Set(stdout.match(SHORTCODE) ?? []),
        reference: stdout.trim(),
      }))
      .catch(() => ({ codes: new Set<string>(), reference: "" }));
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

function hasGitmojiPrefix(subject: string, codes: Set<string>): boolean {
  const trimmed = subject.replace(/^\s+/, "");
  if (/^\p{Extended_Pictographic}/u.test(trimmed)) return true;
  const code = /^(:[a-z0-9_+-]+:)/.exec(trimmed);
  if (code === null) return false;
  return codes.size === 0 || codes.has(code[1]);
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (!isToolCallEventType("bash", event)) return;
    const command = event.input.command;
    if (!command) return;

    const subject = firstCommitSubject(command);
    if (subject === null) return;

    const { codes, reference } = await gitmoji();
    if (hasGitmojiPrefix(subject, codes)) return;

    return {
      block: true,
      reason:
        `This commit message must start with a gitmoji. Got: "${subject}".\n` +
        `Prefix the subject with one of these (the emoji or its :shortcode:), ` +
        `then retry, e.g. git commit -m "✨ ${subject}":\n\n` +
        (reference || "Run `gitmoji -l` to list the available gitmojis."),
    };
  });
}
