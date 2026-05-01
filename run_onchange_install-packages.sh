#!/bin/sh

# IMPORTANT: This script MUST be idempotent as it may be executed multiple times
# by chezmoi's onChange hook. All operations should be safe to run repeatedly
# without causing errors or unexpected behavior.

# Initial system check
echo "================================================"
echo "🔍 SYSTEM COMPATIBILITY CHECK"
echo "================================================"
if [ ! -f /etc/os-release ] || ! grep -q "Ubuntu" /etc/os-release; then
  echo "❌ This script is designed for Ubuntu only"
  echo "📌 Detected system is not Ubuntu - exiting"
  echo "================================================"
  exit 0
fi
echo "✅ Ubuntu system detected - proceeding with installation"
echo ""

# System update section
echo "================================================"
echo "🔄 UPDATING SYSTEM PACKAGES"
echo "================================================"
sudo apt update -y
sudo apt upgrade -y
echo "✅ System update completed successfully"
echo ""

# Regolith installation section
echo "================================================"
echo "🖥️  INSTALLING REGOLITH DESKTOP"
echo "================================================"
# https://regolith-desktop.com/docs/using-regolith/install/
# Version detection
UBUNTU_VERSION=$(lsb_release -sr | cut -d. -f1)
case $UBUNTU_VERSION in
22) UBUNTU_CODENAME="jammy" ;;
24) UBUNTU_CODENAME="noble" ;;
25) UBUNTU_CODENAME="plucky" ;;
*) echo "⚠️  WARNING: Ubuntu $UBUNTU_VERSION is not officially supported by Regolith (expected 22/24/25)" ;;
esac

# Installation process
if [ -n "$UBUNTU_CODENAME" ]; then
  echo "📋 Detected Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME)"
  echo "🔑 Adding Regolith repository key..."
  wget -qO - https://archive.regolith-desktop.com/regolith.key |
    gpg --dearmor | sudo tee /usr/share/keyrings/regolith-archive-keyring.gpg >/dev/null
  echo "📦 Adding Regolith repository..."
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] \
        https://archive.regolith-desktop.com/ubuntu/stable $UBUNTU_CODENAME v3.3" |
    sudo tee /etc/apt/sources.list.d/regolith.list
  echo "🔄 Updating package lists..."
  sudo apt update -y
  echo "🛠️ Installing Regolith core packages..."
  sudo apt install -y regolith-desktop regolith-session-flashback regolith-look-gruvbox
  echo "🛠️ Installing i3xrocks packages..."
  sudo apt install -y \
    i3xrocks-battery \
    i3xrocks-bluetooth \
    i3xrocks-cpu-usage \
    i3xrocks-disk-capacity \
    i3xrocks-focused-window-name \
    i3xrocks-info \
    i3xrocks-media-player \
    i3xrocks-memory \
    i3xrocks-net-traffic \
    i3xrocks-rofication \
    i3xrocks-time
  echo "✅ Regolith installation completed successfully"
  echo "🔄 NOTE: You need to reboot for the new desktop session to appear"
else
  echo "❌ Skipping Regolith installation (unsupported version)"
fi
echo ""

# Additional applications section
echo "================================================"
echo "📦 INSTALLING ADDITIONAL APPLICATIONS"
echo "================================================"
echo "🦊 Removing Firefox (replaced by Zen)..."
sudo snap remove firefox 2>/dev/null || true
sudo apt remove -y firefox 2>/dev/null || true

echo "🦓 Installing Zen browser..."
ZEN_TMP=$(mktemp -d)
curl -fsSL -o "$ZEN_TMP/zen.tar.xz" \
  https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz
sudo rm -rf /opt/zen
sudo tar -xf "$ZEN_TMP/zen.tar.xz" -C /opt
sudo ln -sf /opt/zen/zen /usr/local/bin/zen
sudo tee /usr/share/applications/zen.desktop >/dev/null <<'DESKTOP'
[Desktop Entry]
Name=Zen Browser
GenericName=Web Browser
Comment=Browse the web with Zen
Exec=/opt/zen/zen %U
Icon=/opt/zen/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=zen
Categories=Network;WebBrowser;
DESKTOP
rm -rf "$ZEN_TMP"
echo "📝 Installing Neovim text editor..."
sudo snap install nvim --classic
echo "🦀 Installing Ghostty terminal..."
sudo snap install ghostty --classic
echo "🧰 Installing ripgrep, xclip, fzf..."
sudo apt install -y ripgrep xclip fzf universal-ctags
echo "💻 Installing omzsh..."
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "✅ Additional applications installed successfully"
echo ""

# Git forge CLIs section
echo "================================================"
echo "🐙 INSTALLING GIT FORGE CLIs (gh, tea)"
echo "================================================"
echo "🐙 Installing gh (GitHub CLI)..."
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
sudo install -d -m 0755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg |
  sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
  sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
sudo apt update -y
sudo apt install -y gh

echo "🍵 Installing tea (Forgejo/Gitea CLI)..."
# https://dl.gitea.com/tea/ — bump TEA_VERSION to upgrade
TEA_VERSION="0.11.0"
TEA_ARCH=$(dpkg --print-architecture)
sudo curl -fsSL "https://dl.gitea.com/tea/${TEA_VERSION}/tea-${TEA_VERSION}-linux-${TEA_ARCH}" \
  -o /usr/local/bin/tea
sudo chmod +x /usr/local/bin/tea
echo "✅ Git forge CLIs installed successfully"
echo ""

# Docker installation section
echo "================================================"
echo "🐳 INSTALLING DOCKER"
echo "================================================"
echo "🔑 Adding Docker's official GPG key..."
sudo apt update -y
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "📦 Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

echo "🔄 Updating package lists..."
sudo apt update -y

echo "🛠️ Installing Docker packages..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "👤 Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "✅ Docker installation completed successfully"
echo "🔄 NOTE: You may need to log out and back in for group changes to take effect"
echo ""

# MCP servers section
echo "================================================"
echo "🔌 INSTALLING MCP SERVERS"
echo "================================================"
echo "🐹 Ensuring Go toolchain is available..."
sudo apt install -y golang-go
echo "🔐 Installing age (used by chezmoi for passphrase-based secret encryption)..."
sudo apt install -y age

echo "🪶 Installing rtk (LLM-token-optimizing CLI proxy)..."
# https://github.com/rtk-ai/rtk — official installer, downloads pre-built
# musl binary into ~/.local/bin/rtk. Idempotent: re-runs upgrade in place.
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

echo "🦊 Installing forgejo-mcp via 'go install'..."
# https://codeberg.org/goern/forgejo-mcp — runs as a Claude Code MCP server.
# Module path uses the /v2 suffix per its go.mod. GOTOOLCHAIN=auto lets Go
# fetch a newer toolchain when the project requires one beyond what apt ships.
# Re-run installs latest; binary lands in ~/go/bin/forgejo-mcp.
GOTOOLCHAIN=auto go install codeberg.org/goern/forgejo-mcp/v2@latest

echo "🐙 Installing github-mcp-server via 'go install'..."
# https://github.com/github/github-mcp-server — official GitHub MCP server.
# Main package lives under cmd/github-mcp-server. Binary lands in ~/go/bin.
GOTOOLCHAIN=auto go install github.com/github/github-mcp-server/cmd/github-mcp-server@latest

echo "🔗 Registering forgejo-mcp with Claude Code (user scope)..."
# Token is read from FORGEJO_ACCESS_TOKEN in the parent shell env (sourced from
# ~/.secrets/zshrc_secrets), so it never gets written into ~/.claude.json.
# Re-runs are idempotent: remove + add re-asserts the desired config.
if command -v claude >/dev/null 2>&1; then
  # Use the absolute path to forgejo-mcp: Claude Code spawns MCP children with
  # a sanitized PATH that doesn't include ~/go/bin, so a bare command would
  # fail with "No such file or directory".
  claude mcp remove forgejo --scope user >/dev/null 2>&1 || true
  claude mcp add --transport stdio --scope user forgejo -- \
    "$HOME/go/bin/forgejo-mcp" --transport stdio --url https://git.greil.fr
  claude mcp remove github --scope user >/dev/null 2>&1 || true
  claude mcp add --transport stdio --scope user github -- \
    "$HOME/go/bin/github-mcp-server" stdio
else
  echo "⏭️  claude CLI not found; skipping MCP registration"
fi
echo "✅ MCP servers installed successfully"
echo ""

# Final completion message
echo "================================================"
echo "📝 INSTALLATION COMPLETED"
echo "================================================"
if [ -n "$UBUNTU_CODENAME" ]; then
  echo "🔄 NOTE: You need to reboot for Regolith to appear"
fi
echo "🐳 NOTE: Docker will be available for current user after next login"
