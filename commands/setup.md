---
description: Guided configuration - set your context thresholds and install the Stop hook that enables automatic monitoring
---

Walk the user through configuring claude-auto-handoff. Ask one question at a time.

## Step 1: Threshold

Ask:
> "After how many conversation turns should I offer a handoff? This is when I'll actively suggest creating one. (Press Enter for default: 25)"

Reasonable range: 15-40. Accept the user's answer or use 25.

## Step 2: Early Warning

Ask:
> "Should I give you a quiet early heads-up before the threshold? If yes, at what turn? (Press Enter for default: 21, or type 'no' to disable)"

## Step 3: Write Config

Create the plugin directory and write config:

```bash
mkdir -p ~/.claude/workspace/plugins/auto-handoff
```

Write to `~/.claude/workspace/plugins/auto-handoff/config.json`:

```json
{
  "threshold": [THRESHOLD],
  "warn_at": [WARN_AT or omit if disabled],
  "remind_every": 3,
  "auto_suggest": true
}
```

## Step 4: Install the Hook Script

Copy the hook script to the plugin directory so it has a stable path:

```bash
cp [plugin-dir]/hooks/context-monitor.sh ~/.claude/workspace/plugins/auto-handoff/context-monitor.sh
chmod +x ~/.claude/workspace/plugins/auto-handoff/context-monitor.sh
```

## Step 5: Register the Stop Hook

Tell the user:
> "One last step — add this to your `~/.claude/settings.json` to enable automatic monitoring. Open the file and add the `Stop` hook under `hooks`:"

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${HOME}/.claude/workspace/plugins/auto-handoff/context-monitor.sh\""
          }
        ]
      }
    ]
  }
}
```

If they already have a `Stop` hook, instruct them to add the new entry to the existing array.

## Step 6: Confirm

Say:
> "All set! I'll give you a quiet heads-up at turn [WARN_AT] and offer a handoff at turn [THRESHOLD]. Run `/handoff:setup` any time to adjust these settings."
