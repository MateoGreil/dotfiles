#!/usr/bin/env bash
# Sync chezmoi-owned stable keys into ~/.pi/agent/settings.json.
#
# Why this exists: pi treats settings.json as both user config AND runtime
# state. It writes the last-used model/provider/thinking-level and the
# changelog version on every model switch (agent-session.js setModel ->
# settingsManager.setDefaultModelAndProvider -> save), with no opt-out.
# Version-controlling that file therefore means permanent, meaningless drift.
#
# So ~/.pi/agent/settings.json is listed in .chezmoiignore (chezmoi no longer
# owns it), and THIS script enforces only the stable keys (theme, packages,
# prefs) via a deep merge. pi's runtime keys are preserved untouched.
#
# Idempotent: stable keys win on conflict; runtime keys kept as-is. Re-runs only
# when this file's rendered content changes (chezmoi run_onchange contract) —
# so editing STABLE below is what triggers a re-sync.
set -euo pipefail

TARGET="$HOME/.pi/agent/settings.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "[sync-pi-settings] jq not found — skipping (run install-packages.sh)." >&2
  exit 0
fi

STABLE='{
  "theme": "gruvbox-dark",
  "packages": [
    "npm:@tintinweb/pi-subagents",
    "npm:pi-mcp-adapter",
    "npm:@the-forge-flow/pi-rules",
    "git:github.com/mattpocock/skills",
    "git:github.com/Go-Electra/claude-plugins",
    "npm:pi-nvim",
    "npm:pi-agent-board",
    "npm:pi-web-access",
    "https://github.com/obra/superpowers"
  ],
  "compaction": { "enabled": false },
  "steeringMode": "all",
  "editorPaddingX": 1,
  "showHardwareCursor": false,
  "quietStartup": true,
  "httpIdleTimeoutMs": 60000,
  "enableInstallTelemetry": false,
  "hideThinkingBlock": false,
  "terminal": { "showImages": false }
}'

mkdir -p "$(dirname "$TARGET")"

if [[ -f "$TARGET" ]] && jq -e . "$TARGET" >/dev/null 2>&1; then
  LIVE="$(cat "$TARGET")"
else
  LIVE='{}'
fi

# Deep merge: live first, STABLE overrides. jq '*' recurses into objects;
# arrays are replaced wholesale (packages is repo-canonical). Runtime keys
# (defaultModel, defaultProvider, defaultThinkingLevel, lastChangelogVersion)
# are absent from STABLE and therefore preserved from the live file as-is.
jq -n --argjson live "$LIVE" --argjson stable "$STABLE" '$live * $stable' \
  > "$TARGET.tmp" && mv "$TARGET.tmp" "$TARGET"
