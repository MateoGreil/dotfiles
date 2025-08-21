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
echo "🦀 Installing Alacritty terminal..."
sudo apt install -y alacritty
echo "🦊 Installing Firefox browser..."
sudo apt install -y firefox
echo "📝 Installing Neovim text editor..."
sudo snap install nvim --classic
echo "🧰 Installing ripgrep, xclip..."
sudo apt install ripgrep xclip
echo "✅ Additional applications installed successfully"
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

# Final completion message
echo "================================================"
echo "📝 INSTALLATION COMPLETED"
echo "================================================"
if [ -n "$UBUNTU_CODENAME" ]; then
  echo "🔄 NOTE: You need to reboot for Regolith to appear"
fi
echo "🐳 NOTE: Docker will be available for current user after next login"
