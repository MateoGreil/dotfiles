#!/bin/sh

# System update section
echo "================================================"
echo "🔄 UPDATING SYSTEM PACKAGES"
echo "================================================"
sudo apt update -y
sudo apt upgrade -y
echo "✅ System update completed successfully"
echo ""
