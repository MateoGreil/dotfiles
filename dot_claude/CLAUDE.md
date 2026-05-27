# Global Claude Instructions

## Security & secret leaks

- Be **extremely careful about leaks**. Never commit, push, paste into PRs/issues, send to third-party tools, or otherwise expose secrets, tokens, API keys, SSH keys, passwords, `.env` values, or anything that could leak private data — even temporarily.
- Before every commit, scan the staged diff for tokens, credentials, private hostnames, or paths that shouldn't be public.
- **Rotate-on-sight rule:** if any secret-looking value (API key, token, password, private key, OAuth/JWT, connection string, etc.) appears anywhere in the conversation transcript — pasted by the user, printed by a tool, leaked from a file — immediately stop and tell the user to **rotate that secret now**, even if it was never committed. Treat transcripts as potentially logged.

## Files Claude shouldn't auto-commit

- Never stage or commit `CLAUDE.md` (or nested `**/CLAUDE.md`) unless the user explicitly asks. Treat it like a config file the user owns — propose changes, but never bundle them into unrelated commits.
- Never stage or commit anything under `docs/superpowers/` unless the user explicitly asks. Same reasoning — user-owned content, never auto-bundled.

## Editor — Neovim

The user works in Neovim (LazyVim) and typically launches Claude Code from inside an nvim `:terminal`. When Claude is a child of nvim, the parent's RPC socket path is exposed in the `$NVIM` env var (e.g. `/run/user/1000/nvim.<PID>.0`). If `$NVIM` is empty, scan `$XDG_RUNTIME_DIR/nvim.*.0` and ask the user which to target if multiple match.

**Hand-off rule** — anything the user would copy out of chat (file contents, long snippets, scripts, configs, generated text) **does not go in the chat**. Write it to a real file — a chezmoi source path, an existing project file, or `/tmp/scratch-<topic>.<ext>` for ephemeral output — and open that file in the user's nvim via the RPC socket. The chat is for conversation and short reasoning, not as a clipboard.

```sh
# Open a file in a vertical split (most common)
nvim --server "$NVIM" --remote-send '<C-\><C-n>:vsplit /abs/path<CR>'

# Horizontal split / new tab
nvim --server "$NVIM" --remote-send '<C-\><C-n>:split /abs/path<CR>'
nvim --server "$NVIM" --remote-send '<C-\><C-n>:tabnew /abs/path<CR>'

# Run an Ex or user command (e.g. :ThemeReload)
nvim --server "$NVIM" --remote-send ':SomeCommand<CR>'

# Evaluate Vimscript and capture the result
nvim --server "$NVIM" --remote-expr 'expand("%:p")'
```

After opening, just tell the user what you opened and where — not the content. Inline code in chat is still fine for ≤5-line examples that are part of an explanation.

## Branching Workflow

- Never commit directly to `main` (or `master`) — always work on a PR branch.
- One new branch per feature. Create it before starting work; name it descriptively (e.g. `feat/<topic>`, `fix/<topic>`).
- For large features, split the work into multiple stacked sub-branches (e.g. `feat/<topic>-part-1`, `feat/<topic>-part-2`) — each should open its own PR for incremental review.
- If the current branch is `main`/`master` when a task starts, create and switch to a new branch before making changes.
- **Exception — chezmoi dotfiles repo** (`~/.local/share/chezmoi`): commit and push directly to `main`. No branches, no PRs.

## Worktrees — always isolate agent work

- **Before making any code changes, always work in a git worktree.** This prevents conflicts when multiple agents (background jobs, parallel sessions, subagents) touch the same repo at the same time, and keeps the user's working copy untouched.
- Use the `EnterWorktree` tool when available (it creates and switches into an isolated worktree). If it isn't available, fall back to `git worktree add ../<repo>-<branch> -b <branch>` and `cd` into that path before editing.
- **Skip the worktree only when:** the task is read-only (search, questions, explaining code), your cwd is already under `.claude/worktrees/`, or you're in the chezmoi dotfiles repo (which has its own commit-to-main exception).
- If `EnterWorktree` fails for any reason, report the failure to the user and continue in place — don't silently work around it.
- When done, hand the branch off via PR as usual; the worktree itself can be cleaned up with `ExitWorktree` or `git worktree remove`.

## Opening the PR

Once the feature is implemented, committed, and pushed, open the PR without waiting to be asked again:

- On Forgejo/Gitea remotes:
  - **Preferred:** when the forgejo MCP is loaded (tools matching `mcp__forgejo__*` are available), use `mcp__forgejo__create_pull_request`. Same goes for any other Forgejo work — listing/creating issues, fetching file content, posting comments, etc. Use the matching `mcp__forgejo__*` tools rather than `tea` or curl.
  - **Fallback:** if the MCP isn't loaded (e.g. fresh machine, session predates the MCP registration), use [`tea`](https://dl.gitea.com/tea/): `tea pr create --title "<emoji> <subject>" --description "<body>"`.
- On GitHub remotes:
  - **Preferred:** when the github MCP is loaded (tools matching `mcp__github__*` are available), use `mcp__github__create_pull_request`. Same for any other GitHub work — issues, PR reviews, file content, comments, workflows, etc. Use the matching `mcp__github__*` tools rather than `gh` or curl.
  - **Fallback:** if the MCP isn't loaded, use `gh pr create --title ... --body ...`.
- The **title** must follow the gitmoji rules above (one emoji, imperative, < 60 chars) — generally mirror the main commit subject.
- The **description** must include:
  - A `## Summary` section with 1–3 bullets explaining *what changed and why* (not a commit-by-commit list).
  - A `## Test plan` section with a checklist of what was verified or still needs to be verified.
  - Links to related issues/PRs when relevant (`Closes #123`, `Refs #456`).
- Never add `Co-Authored-By` trailers or self-referential marketing ("Generated with…"). Keep the body focused on the change.
- After creation, report the PR URL back to the user.

## Commit Messages — Gitmoji

Always use the [gitmoji](https://gitmoji.dev/) convention for commit messages.

Format:
```
<emoji> [scope?][:?] <message>

[optional body]
```

Rules:
- Use one emoji per commit (unicode or `:shortcode:` format)
- Priority: 💥 breaking > ✨ feature > 🐛 fix > ♻️ refactor
- Subject under 60 characters, imperative mood
- Use the body to explain *why*, not *what*
- Reference issues when applicable

Common emojis (full list at https://gitmoji.dev/api/gitmojis):

| Emoji | Intent |
|-------|--------|
| ✨ | New feature |
| 🐛 | Bug fix |
| 💥 | Breaking change |
| ♻️ | Refactor |
| 📝 | Documentation |
| 🎨 | Code style / structure |
| ⚡️ | Performance |
| ✅ | Tests |
| 🔧 | Configuration |
| 🚀 | Deploy |
| 🗑️ | Remove code/files |
| 🔒️ | Security fix |
| ⬆️ | Upgrade dependencies |
| ⬇️ | Downgrade dependencies |
| 🌐 | Internationalization |
| 💄 | UI / styles |
| 🏗️ | Architecture change |
