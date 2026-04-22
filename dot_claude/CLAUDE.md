# Global Claude Instructions

## Branching Workflow

- Never commit directly to `main` (or `master`) — always work on a PR branch.
- One new branch per feature. Create it before starting work; name it descriptively (e.g. `feat/<topic>`, `fix/<topic>`).
- For large features, split the work into multiple stacked sub-branches (e.g. `feat/<topic>-part-1`, `feat/<topic>-part-2`) — each should open its own PR for incremental review.
- If the current branch is `main`/`master` when a task starts, create and switch to a new branch before making changes.

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
