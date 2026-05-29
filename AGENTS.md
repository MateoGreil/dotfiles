# AGENTS.md

Guidance for AI agents / coding assistants working in this repository. This is the tool-agnostic instructions file that most agent managers read directly; `CLAUDE.md` imports it so Claude Code picks it up too. **Keep all guidance here, not in `CLAUDE.md`.**

## What this repo is

Personal **dotfiles managed by [chezmoi](https://www.chezmoi.io/)** for an Ubuntu + [Regolith](https://regolith-desktop.com/) (i3) desktop. This directory (`~/.local/share/chezmoi`) **is chezmoi's source directory** — the files here are chezmoi *source state*, not the live config. Bootstraps with `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply MateoGreil`.

## Source ≠ destination

Editing `dot_zshrc` here does **not** change the live `~/.zshrc` until something captures or applies it. Keep the two clearly separate in your head: source files live here (with chezmoi naming, see below); destination files are the real paths under `~`.

## Workflow for changing the user's environment — ALWAYS follow this loop

When the user asks to change anything in their environment, **do not edit the source here and `chezmoi apply`.** Instead:

1. **Edit the live file *outside* this repo** — the real destination path under `~` (e.g. `~/.zshrc`, `~/.config/ghostty/config.ghostty`, `~/.local/bin/foo`). This lets the user see and test the change immediately on the running system.
2. **Stop and let the user try it.** Do not capture anything into the repo yet.
3. **If it works:** `chezmoi add <live path>` to pull the change into the source here, then `git commit` and `git push` straight to `main`.
   **If it doesn't:** go back to step 1 and iterate on the live file.

The repo is only ever updated *after* the user validates the live change. Never short-circuit this by editing source + `chezmoi apply`.

## Git workflow for THIS repo

- Push **directly to `main`**. **Never** create a branch, **never** open a PR, **never** use a git worktree for this repo. (These override the global branching/worktree rules, which are for other repos.)
- Commits happen only at step 3 above, after the user validates — `chezmoi add` then commit + push.
- gitmoji commit messages (one emoji, imperative, < 60 chars). Do **not** auto-commit `AGENTS.md` / `CLAUDE.md` unless the user asks.
- `dot_claude/CLAUDE.md` here is the *source* for `~/.claude/CLAUDE.md` (global Claude instructions), not this repo's guide — it's a managed dotfile like any other.

## Source-state naming conventions (what the prefixes mean)

chezmoi derives the destination path and attributes from the source filename. The conventions in use here:

| Source name | Destination / effect |
|---|---|
| `dot_zshrc` | `~/.zshrc` (`dot_` → `.`) |
| `private_dot_config/` | `~/.config/` with private (`0600`-style) perms |
| `executable_switch-theme` | `~/.local/bin/switch-theme`, +x |
| `*.tmpl` | Go template, rendered with chezmoi data (e.g. `dot_gitconfig.tmpl` uses `{{ .email }}` / `{{ .name }}`) |
| `encrypted_zshrc_secrets.age` | age-decrypted on apply → `~/.secrets/zshrc_secrets` |
| `run_onchange_install-packages.sh` | script chezmoi runs **whenever its rendered content changes** |

Prefixes stack and apply to directories too (`private_dot_config`, `private_dot_local`). `chezmoi add` applies the right prefixes automatically based on the live file's perms/path.

## Common commands

```sh
chezmoi add ~/.config/foo    # capture a (validated) live file into the source  ← step 3
chezmoi diff                 # preview what apply would change
chezmoi cat ~/.gitconfig     # show the rendered result for a target (renders templates)
chezmoi managed              # list every path chezmoi controls
chezmoi execute-template < f # render a template snippet against this machine's data
chezmoi apply               # write source → ~ (rarely needed given the loop above; also re-runs changed run_onchange scripts)
```

There is no build/test/lint suite. "Verifying" a change means the user tries the live file (step 2); for scripts, also read them for idempotency.

## Architecture / structure

- **`run_onchange_install-packages.sh`** — the machine bootstrapper. Ubuntu-only (exits otherwise). Installs Regolith, Zen browser, Neovim, Ghostty, Docker, OpenTofu, dev tooling, AI CLIs (Claude Code, Mistral Vibe), and registers the forgejo/github MCP servers with Claude Code. chezmoi re-runs it on any content change, so **every operation must stay idempotent** (the header enforces this) — guard installs, use `remove + add` to re-assert config, `|| true` on best-effort steps.
- **`run_onchange_install-zen-userjs.sh.tmpl`** — syncs `private_dot_config/zen/{user.js,chrome/userChrome.css}` into the active Zen profile. Re-runs when those files change (their `sha256sum` is embedded in the template, so the rendered content changes with them).
- **Theme system (dark/light gruvbox).** `dark` is the repo's canonical default. `executable_switch-theme` flips dark↔light by editing **live destination files only** (GTK settings, Xresources bar overrides, Ghostty) plus a `~/.config/theme-mode` sentinel — it intentionally does *not* touch source state, so `chezmoi apply` resets to dark. nvim's `colorscheme.lua` reads that sentinel on startup and via `:ThemeReload`.
- **Desktop integration** (`private_dot_config/regolith3/i3/config.d/`): `claude-scratch` (Super+Shift+A → `executable_claude-scratch-toggle` spawns/toggles a floating Ghostty running `claude` in `/tmp/claude`, matched by WM_CLASS `dev.mat.ClaudeScratch`); `herbe-notifications` (`executable_herbe-notifications` sniffs D-Bus `Notify` calls and pops them via the `herbe` daemon).
- **Neovim** (`private_dot_config/nvim/`): LazyVim + lazy.nvim. `lua/plugins/claudecode.lua` ships a custom claudecode.nvim terminal provider that opens Claude in the *current* window; `init.lua` auto-runs `ClaudeCode agents` when nvim opens a directory.
- **Secrets**: `dot_secrets/encrypted_zshrc_secrets.age` is age-encrypted; decrypts to `~/.secrets/zshrc_secrets`, sourced by `.zshrc` (holds tokens like `FORGEJO_ACCESS_TOKEN` used by the install script). The age identity and chezmoi data live machine-locally in `~/.config/chezmoi/chezmoi.toml` — **not** in this repo. Never commit plaintext secrets; edit via `chezmoi edit dot_secrets/encrypted_zshrc_secrets.age`.

## Conventions for changes here

- Touching either `run_onchange_*` script → preserve idempotency; it re-runs on the next apply for everyone.
- Anything machine-specific (email, name, secrets, age key) belongs in chezmoi data / `~/.config/chezmoi`, surfaced via `.tmpl` or encryption — never hardcoded in source.
