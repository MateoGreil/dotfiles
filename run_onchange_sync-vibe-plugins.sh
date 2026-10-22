#!/usr/bin/env bash
# Ensure the git-cloned Vibe plugins exist under ~/.vibe/plugins.
#
# Plugins are git clones (Claude Code plugin format, adapted natively by
# Vibe: skills only). They are NOT version-controlled here — this script
# only bootstraps missing clones so a fresh machine gets them via
# `chezmoi apply`. Day-to-day updates run `update-vibe-plugins` (~/.local/bin),
# which pulls every clone.
#
# Idempotent: clones only when a directory is missing; existing clones are
# left untouched (their updates are user-driven). Re-runs when this file's
# rendered content changes (chezmoi run_onchange contract) — so editing
# PLUGINS below is what triggers a re-sync.
set -euo pipefail

PLUGINS_DIR="$HOME/.vibe/plugins"
PLUGINS=(
  "https://github.com/mattpocock/skills|mattpocock-skills"
  "https://github.com/obra/superpowers|superpowers"
)

if ! command -v git >/dev/null 2>&1; then
  echo "[sync-vibe-plugins] git introuvable — ignoré." >&2
  exit 0
fi

for entry in "${PLUGINS[@]}"; do
  url="${entry%%|*}"
  name="${entry##*|}"
  dir="$PLUGINS_DIR/$name"
  if [[ -d "$dir/.git" ]]; then
    echo "[sync-vibe-plugins] $name déjà cloné — laissé tel quel."
  else
    echo "[sync-vibe-plugins] clone de $name…"
    mkdir -p "$PLUGINS_DIR"
    git clone --quiet "$url" "$dir"
  fi
done
