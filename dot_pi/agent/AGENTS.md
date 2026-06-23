# Global agent instructions (pi)

## Prefer these CLIs over any MCP/connector for their service

Installed & authenticated locally — reach for these instead of an MCP.

- **Forgejo / `git.greil.fr`** → `tea` CLI
- **GitHub** → `gh` CLI
- **Salesforce / Sitetracker** → `sf` CLI
- **Terraform** → `terraform` CLI
- **OpenTofu** → `tofu` CLI
- **Google Workspace** (Drive, Sheets, Gmail, Calendar, Docs, Slides, Meet) → `gws` CLI
- **Slack** → `slackcli` CLI

(Configured MCP servers are discoverable at runtime via the `mcp` tool, so they're not listed here.)

## Git worktrees

Always work in a dedicated **git worktree** rather than directly in the main checkout, so multiple agents running in parallel don't step on each other (conflicting edits, half-applied changes, racing on the same branch). One worktree per task. (A repo's own `AGENTS.md` may override this — e.g. the chezmoi dotfiles repo forbids worktrees.)

## Development work

When a task requires actual development (writing or changing code across multiple steps), use the **`/subagent-driven-development`** workflow rather than implementing everything inline.

## Code comments

Do **not** add comments to code unless explicitly asked. Write self-explanatory code (clear names, small functions) instead of explaining it with comments. Only add a comment when the user explicitly requests one, or to preserve an existing comment that's still relevant.
