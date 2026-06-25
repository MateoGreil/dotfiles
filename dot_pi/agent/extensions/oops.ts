import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("oops", {
    description: "Rewind to your last message and put it back in the editor",
    handler: async (_args, ctx) => {
      if (!ctx.isIdle()) {
        ctx.ui.notify("Interrupt the agent (esc) before /oops.", "warning");
        return;
      }
      const lastUserMessage = ctx.sessionManager
        .getBranch()
        .findLast((entry) => entry.type === "message" && entry.message.role === "user");
      if (!lastUserMessage) {
        ctx.ui.notify("No message to edit.", "info");
        return;
      }
      await ctx.navigateTree(lastUserMessage.id);
    },
  });
}
