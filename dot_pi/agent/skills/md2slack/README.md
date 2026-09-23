# md2slack (Linux fork)

A [Claude Code](https://claude.ai/code) skill that turns a Markdown table into a **native Slack table** — no pandoc, no macOS.

Fork of [loslcrd/md2slack](https://github.com/loslcrd/md2slack) (macOS + pandoc + osascript), rewritten for Linux with two delivery paths.

## Why

Slack ignores plain-text Markdown tables. It does, however:

- detect `<table>` HTML on the `text/html` clipboard flavor and offer to render it as a native table block on paste;
- accept a top-level `table` block (rows of `rich_text` cells) via `chat.postMessage`.

This skill covers both: clipboard for manual paste, API for direct posting.

## Requirements

- Linux, `python3`
- Clipboard path: PyGObject + GTK4 (`python3-gi`, `gir1.2-gtk-4.0`)
- API path: [slackcli](https://github.com/ksred/slackcli) authenticated with browser session tokens

## Installation

```bash
claude skill install https://github.com/MateoGreil/md2slack
```

## Usage

> "Send this table to Slack"
> "Paste this into Slack"
> "Post this table in #my-channel"
> `/md2slack`

## How it works

Clipboard path:

```
Markdown table → md2slack.py (pure-Python GFM table → HTML + TSV)
              → clip_table.py (GTK4 ContentProvider: text/html + text/plain flavors)
              → Ctrl+V in Slack → "format as table?" prompt
```

API path:

```
Markdown table → send_slack_table.py (table → Slack `table` block of rich_text cells)
              → chat.postMessage (slackcli browser credentials)
              → native table posted, links/bold/code preserved
```

The dual clipboard flavor matters: HTML alone looks like an *empty* clipboard to plain-text apps; the TSV flavor keeps paste working everywhere (and pastes clean columns into spreadsheets).
