#!/bin/sh

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

# Version detection
UBUNTU_VERSION=$(lsb_release -sr | cut -d. -f1)
case $UBUNTU_VERSION in
    22) UBUNTU_CODENAME="jammy" ;;
    24) UBUNTU_CODENAME="noble" ;;
    25) UBUNTU_CODENAME="plucky" ;;
    *)  echo "⚠️  WARNING: Ubuntu $UBUNTU_VERSION is not officially supported by Regolith (expected 22/24/25)" ;;
esac

# Installation process
if [ -n "$UBUNTU_CODENAME" ]; then
    echo "📋 Detected Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME)"
    echo "🔑 Adding Regolith repository key..."
    wget -qO - https://archive.regolith-desktop.com/regolith.key | \
        gpg --dearmor | sudo tee /usr/share/keyrings/regolith-archive-keyring.gpg > /dev/null

    echo "📦 Adding Regolith repository..."
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] \
        https://archive.regolith-desktop.com/ubuntu/stable $UBUNTU_CODENAME v3.3" | \
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

# Additional applications section
echo ""
echo "================================================"
echo "📦 INSTALLING ADDITIONAL APPLICATIONS"
echo "================================================"
echo "🦀 Installing Alacritty terminal..."
sudo apt install -y alacritty
echo "🦊 Installing Firefox browser..."
sudo apt install -y firefox
echo "📝 Installing Neovim text editor..."
sudo apt install -y nvim
echo "✅ Additional applications installed successfully"

echo ""
echo "================================================"
echo "📝 INSTALLATION COMPLETED"
echo "================================================"
if [ -n "$UBUNTU_CODENAME" ]; then
    echo "🔄 NOTE: You need to reboot for Regolith to appear"
fi
