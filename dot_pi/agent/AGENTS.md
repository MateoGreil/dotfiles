# Global agent instructions (pi)

## Prefer these CLIs over any MCP/connector for their service

Installed & authenticated locally — reach for these instead of an MCP.

- **Forgejo / `git.greil.fr`** → `tea` CLI
- **GitHub** → `gh` CLI
- **Salesforce / Sitetracker** → `sf` CLI

(Configured MCP servers are discoverable at runtime via the `mcp` tool, so they're not listed here.)

## Code comments

Do **not** add comments to code unless explicitly asked. Write self-explanatory code (clear names, small functions) instead of explaining it with comments. Only add a comment when the user explicitly requests one, or to preserve an existing comment that's still relevant.
