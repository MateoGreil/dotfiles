---
name: md2slack
description: Send a Markdown table to Slack as a native table block — either by loading the Linux clipboard (text/html + TSV flavors) so pasting into Slack triggers its "format as table?" prompt, or by posting directly to a channel/DM via the Slack API. Use whenever the user wants to send, paste, share, or post a table to Slack, or when the assistant has produced a Markdown table and Slack is mentioned. Linux only, no pandoc needed.
---

# md2slack (Linux)

Slack renders a native table block in two situations:

1. **Paste**: Slack detects a `<table>` element in the `text/html` clipboard flavor and offers to render it as a native table. A plain-text flavor must be present alongside, otherwise text apps (and some Slack builds) see an "empty" clipboard.
2. **API**: `chat.postMessage` accepts a top-level block of type `table` (rows of `rich_text` cells) — this posts a native table without any manual paste.

All three scripts live next to this file. No pandoc: the Markdown table is parsed and converted in pure Python.

## Requirements

- Linux, `python3`
- Clipboard path: PyGObject + GTK4 (`python3-gi` + `gir1.2-gtk-4.0`), X11 or Wayland session
- API path: `slackcli` authenticated with browser tokens (`~/.config/slackcli/workspaces.json`)

## Input source

The table to convert comes from one of these two sources only:

1. A Markdown table the user provided in their current message (or a file they explicitly pointed to).
2. A Markdown table the assistant produced earlier in the conversation.

Do NOT read from the user's clipboard or arbitrary files on disk. If neither source is available, ask the user to provide the table.

## What to do

Write the Markdown table to a file (e.g. `/tmp/table.md`), then pick a path:

- User wants to paste it themselves, or no channel is known → **clipboard path**.
- User asks to send/post it and a channel or DM id is known → **API path**.

### Clipboard path

```bash
python3 <skill_dir>/md2slack.py /tmp/table.md --html-out /tmp/table.html --tsv-out /tmp/table.tsv
setsid nohup python3 <skill_dir>/clip_table.py /tmp/table.html /tmp/table.tsv > /tmp/clip_table.log 2>&1 &
```

Verify both flavors are served, then tell the user to switch to Slack and paste (Ctrl+V):

```bash
xclip -selection clipboard -t TARGETS -o
```

Expected: `text/html` AND `text/plain` in the list. The `clip_table.py` process must stay alive to serve pastes (`setsid` detaches it); any later copy by the user takes ownership back — just relaunch it.

### API path

```bash
python3 <skill_dir>/send_slack_table.py /tmp/table.md CHANNEL_ID "optional intro text"
```

Posts the first Markdown table of the file as a native `table` block. Header row is bold; `[text](url)` links, `` `code` `` and `**bold**` in cells are preserved. Prints `{"ok": true, ...}` on success.

## Failure modes

- **`No module named gi` / GTK4 typelib missing** → `sudo apt install python3-gi gir1.2-gtk-4.0`.
- **"no display available"** → no X11/Wayland session (`DISPLAY`/`WAYLAND_DISPLAY` unset); use the API path instead.
- **Paste shows nothing in text apps** → only `text/html` was on the clipboard (e.g. raw `xclip -t text/html`); use `clip_table.py`, which serves both flavors.
- **Clipboard "lost"** → the user copied something else; relaunch `clip_table.py`.
- **`invalid_auth` from the API path** → `slackcli` is not authenticated with browser tokens (`slackcli auth login-browser`); app tokens (xoxb/xoxp) may lack the custom `table` block privilege.
- **"no Markdown table found"** → malformed table (missing `|---|` separator row).
