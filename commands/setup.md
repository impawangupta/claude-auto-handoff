---
description: Configure handoff thresholds - asks 2 questions only. Run this if you want to change the defaults (warn: 21 turns, handoff: 25 turns).
---

Configure handoff thresholds. Ask only 2 questions.

## Step 1: Show Current Settings

Check `~/.claude/workspace/plugins/handoff/config.json`.

If it exists, show:
> "Current settings: early warning at turn [warn_at], handoff offer at turn [threshold]."

## Step 2: Ask Only These 2 Questions

Ask one at a time:

1. "At what turn should I quietly flag the session is getting long? (default: 21)"
2. "At what turn should I actively offer a handoff? (default: 25)"

Accept Enter/blank to keep the default.

## Step 3: Write Config Silently

```bash
mkdir -p ~/.claude/workspace/plugins/handoff
```

Write `~/.claude/workspace/plugins/handoff/config.json`:

```json
{
  "threshold": [answer 2 or 25],
  "warn_at": [answer 1 or 21],
  "remind_every": 3,
  "auto_suggest": true
}
```

## Step 4: Confirm

Say:
> "Done — I'll flag at turn [warn_at] and offer a handoff at turn [threshold]."
