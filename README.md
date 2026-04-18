# dotfiles

This repository contains my dotfiles and configuration scripts for setting up a development environment on [Ubuntu](https://ubuntu.com/), primarily tailored for [Regolith Desktop](https://regolith-desktop.com/), [Neovim](https://neovim.io/) (Lua-based configuration), shell customization, and [Claude Code](https://claude.ai/code) AI assistant integration. It leverages [chezmoi](https://www.chezmoi.io/) for dotfile management. Notifications are handled by [Rofication](https://github.com/regolith-linux/rofication) with [herbe](https://github.com/dudik/herbe) for popup display.

![Screenshot 1](screenshot1.png)

![Screenshot 2](screenshot2.png)

## Installation (Quick Start)

1. **Install Ubuntu**  
   [Download Ubuntu Desktop](https://ubuntu.com/download/desktop) and install it.

2. **Install chezmoi and apply this dotfiles repo**
   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply MateoGreil
   ```
   This will clone and install all configuration files and scripts in your home directory.

3. **Reboot** after install for desktop session and configs to take full effect.

## What Gets Installed and Configured?

### Desktop Environment

- **Regolith Desktop** (i3-based environment for Ubuntu)
  - Scripted install via `run_onchange_install-packages.sh` (idempotent, auto-run by chezmoi)
  - Installs Regolith, core packages, and i3xrocks system monitors
  - Applies custom look: Gruvbox theme and custom wallpaper
  - Xresources config sets up desktop bar, wallpaper file, and other appearance settings

### Shell

- **Zsh** setup with Oh My Zsh:
  - Theme: `robbyrussell`
  - Custom options and plugin comments in `.zshrc`

### Neovim

- **Neovim**
  - Scripted install via `run_onchange_install-packages.sh` (idempotent, auto-run by chezmoi)
  - Uses [LazyVim](https://www.lazyvim.org/) framework
  - Plugin management via `lazy.nvim` ([folke/lazy.nvim](https://github.com/folke/lazy.nvim))
  - Custom keymaps for navigation, window resizing, clipboard integration, and more
  - Options and appearance tweaks (see `lua/config/options.lua`)
  - Gruvbox themed (set to 120)

### Notifications

- **Rofication** — silent notification queue (default in Regolith)
- **herbe** — lightweight popup overlay for all incoming notifications, with sound via `paplay`
- A D-Bus sniffer script (`~/.local/bin/herbe-notifications`) auto-started by i3

### Claude Code

- **Claude Code** settings (`~/.claude/settings.json`)
  - Stop hook: sends a desktop notification with Claude's last response when a task finishes

### Other System and package dependencies (from scripts):

- **APT Updates** via `run_onchange_install-packages.sh`
- Miscellaneous utilities as needed (see `run_onchange_install-packages.sh`)

## Customization

After running chezmoi:
- Modify Neovim configs in `.config/nvim/`
- Change Regolith settings in `.config/regolith3/Xresources` and wallpaper
- Update shell environment via `.zshrc`

Don't forget to update chezmoi with `chezmoi add <file>`, `chezmoi cd` and add to git the diffs

## Notes

- This setup expects to run on **Ubuntu** only; it will exit on other systems.
- Scripts and configs are idempotent: safe to re-run when updating.

## References

- [chezmoi documentation](https://www.chezmoi.io/docs/)
- [Regolith Desktop](https://regolith-desktop.com/)
- [LazyVim](https://www.lazyvim.org/)
- [Avante.nvim](https://github.com/yetone/avante.nvim)
- [herbe](https://github.com/dudik/herbe)
- [Claude Code](https://claude.ai/code)
