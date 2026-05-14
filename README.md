# claude-auto-handoff

Automatically monitors context length and offers to hand off to a fresh Claude Code session — before response quality degrades.

No more manually tracking how long your session has been running. Claude watches the context size and politely lets you know when it's time.

## Install

Inside Claude Code:

```
/plugin marketplace add impawangupta/claude-auto-handoff
/plugin install auto-handoff
```

Then run the guided setup:

```
/handoff:setup
```

This sets your thresholds and installs the Stop hook that enables automatic monitoring.

## How It Works

A Stop hook runs after every Claude response and tracks how many turns the session has had.

| Turn | What happens |
|------|-------------|
| 21 (warn_at) | Claude notes internally — no interruption |
| 25 (threshold) | Claude politely offers a handoff |
| Every 3 turns after | Gentle reminder if you haven't acted |

When you confirm, Claude:
1. Runs `git status`, `git diff`, `git log` to gather context
2. Writes a structured `HANDOFF.md`
3. Tells you to open a fresh `claude` session — which auto-detects the handoff

## Commands

| Command | Description |
|---------|-------------|
| `/handoff` | Guided — Claude gathers context then asks you 5 questions |
| `/handoff:create` | Automatic — infers everything, no questions |
| `/handoff:quick` | Minimal — essentials only, fast |
| `/handoff:resume` | Resume from an existing `HANDOFF.md` |
| `/handoff:setup` | Configure thresholds and install the hook |

## Handoff Format

Every `HANDOFF.md` follows this structure:

```markdown
# Handoff: [brief title]

**Generated**: 2025-05-14 16:30
**Branch**: feature/auth
**Status**: In Progress

## Goal
- Add OAuth2 login with Google.

## Current state
- Login endpoint returns valid tokens.
- Refresh logic is stubbed but untested.

## Files touched
- src/auth/oauth.ts
- src/routes/login.ts

## What changed
- Added Google OAuth2 provider config.
- Created /api/login endpoint.

## What failed
- Tried passport.js — conflicted with existing Express middleware.
- Switched to oauth4webapi which works directly with fetch.

## Next steps
- Open a fresh Claude Code session.
- Read this handoff file first.
- Fix the refresh endpoint at src/auth/refresh.ts:42.
- Add logout: clear httpOnly cookie, POST /api/auth/logout.
```

`Next steps` always opens with those two fixed lines — so the next session always knows exactly what to do first.

## Project-Level Config

Override thresholds for a specific project by adding `.claude-auto-handoff.json` to the project root:

```json
{
  "threshold": 30,
  "warn_at": 25,
  "remind_every": 5
}
```

This overrides your global `~/.claude/workspace/plugins/auto-handoff/config.json` for that project only.

## Global Config

Located at `~/.claude/workspace/plugins/auto-handoff/config.json`:

```json
{
  "threshold": 25,
  "warn_at": 21,
  "remind_every": 3,
  "auto_suggest": true
}
```

| Key | Default | Description |
|-----|---------|-------------|
| `threshold` | 25 | Turns before Claude offers handoff |
| `warn_at` | 21 | Turns before quiet internal warning |
| `remind_every` | 3 | How often to remind after threshold |
| `auto_suggest` | true | Enable automatic suggestions |

## Manual Hook Setup

If `/handoff:setup` doesn't work for your environment, add this to `~/.claude/settings.json`:

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

Then copy the hook script:

```bash
mkdir -p ~/.claude/workspace/plugins/auto-handoff
cp hooks/context-monitor.sh ~/.claude/workspace/plugins/auto-handoff/context-monitor.sh
chmod +x ~/.claude/workspace/plugins/auto-handoff/context-monitor.sh
```

## Tips

1. **Run `/handoff` before you stop** — the guided version lets you add context Claude can't infer from git.

2. **`What failed` is the most valuable section** — "Tried X, it broke because Y" saves hours in the next session.

3. **Use project-level config** — long exploratory sessions need a higher threshold than focused bug fixes.

4. **For non-git projects** — everything still works, the git sections are simply omitted.

5. **Any AI can resume** — `HANDOFF.md` is plain markdown. Just tell another agent: "Read HANDOFF.md and continue the work."

## License

MIT
