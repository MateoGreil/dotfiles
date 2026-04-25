# Global Claude Instructions

## CLAUDE.md

- Never stage or commit `CLAUDE.md` (or nested `**/CLAUDE.md`) unless the user explicitly asks. Treat it like a config file the user owns — propose changes, but never bundle them into unrelated commits.

## Branching Workflow

- Never commit directly to `main` (or `master`) — always work on a PR branch.
- One new branch per feature. Create it before starting work; name it descriptively (e.g. `feat/<topic>`, `fix/<topic>`).
- For large features, split the work into multiple stacked sub-branches (e.g. `feat/<topic>-part-1`, `feat/<topic>-part-2`) — each should open its own PR for incremental review.
- If the current branch is `main`/`master` when a task starts, create and switch to a new branch before making changes.
- **Exception — chezmoi dotfiles repo** (`~/.local/share/chezmoi`): commit and push directly to `main`. No branches, no PRs.

## Opening the PR

Once the feature is implemented, committed, and pushed, open the PR without waiting to be asked again:

- On Forgejo/Gitea remotes, use [`tea`](https://dl.gitea.com/tea/): `tea pr create --title "<emoji> <subject>" --description "<body>"`.
- On GitHub remotes, use `gh pr create --title ... --body ...`.
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
