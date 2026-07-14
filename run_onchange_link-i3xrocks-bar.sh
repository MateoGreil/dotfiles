#!/bin/sh
# Regolith runs the bar as:
#   i3xrocks -u ~/.config/regolith3/i3xrocks/conf.d -d /usr/share/i3xrocks/conf.d
# The -u (user) dir REPLACES the -d (default) dir; it does NOT merge. So the moment
# the user conf.d holds any file, every stock block (time, cpu, battery, ...) vanishes.
# To keep the stock blocks alongside our own 85_pi-agents block, symlink the stock
# blocks into the user conf.d. (85_pi-agents itself is a real chezmoi-managed file.)
set -eu

USER_DIR="$HOME/.config/regolith3/i3xrocks/conf.d"
SYS_DIR="/usr/share/i3xrocks/conf.d"

[ -d "$SYS_DIR" ] || exit 0
mkdir -p "$USER_DIR"

# Drop stale symlinks, keep real files (our 85_pi-agents), then relink current stock blocks.
find "$USER_DIR" -maxdepth 1 -type l -delete
for f in "$SYS_DIR"/*; do
    [ -e "$f" ] || continue
    ln -sf "$f" "$USER_DIR/$(basename "$f")"
done
