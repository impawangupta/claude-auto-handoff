# claude-auto-handoff

Automatically monitors context length and offers to hand off to a fresh Claude Code session — before response quality degrades.

No more manually tracking how long your session has been running. Claude watches the context size, politely lets you know when it's time, and handles everything automatically.

## Install

Inside Claude Code:

```
/plugin marketplace add impawangupta/claude-auto-handoff
/plugin install handoff
```

That's it. No setup required — defaults are applied automatically on first use.

If you want to change the thresholds, run:

```
/handoff:setup
```

## How It Works

A Stop hook runs after every Claude response and tracks how many turns the session has had.

| Turn | What happens |
|------|-------------|
| 21 (warn_at) | Claude notes internally — no interruption to you |
| 25 (threshold) | Claude politely offers a handoff |
| Every 3 turns after | Gentle reminder if you haven't acted |

When you confirm, Claude:
1. Reads the full conversation and runs `git status`, `git diff`, `git log`
2. Writes a structured handoff document to `~/.claude/workspace/plugins/handoff/handoffs/`
3. Sets a resume flag and tells you to type `/clear`
4. After you type `/clear`, automatically resumes from the handoff on the next interaction — no questions asked

## Commands

| Command | Description |
|---------|-------------|
| `/handoff` | Fully automatic — generates handoff from conversation + git, tells you to `/clear` |
| `/handoff:create` | Same as above without the resume flow — just writes the file |
| `/handoff:quick` | Minimal handoff — essentials only, fast |
| `/handoff:resume` | Resume from the most recent handoff for this project |
| `/handoff:setup` | Change thresholds — asks 2 questions only |

## Handoff File Location

Handoffs are saved to your Claude workspace — never to your project directory:

```
~/.claude/workspace/plugins/handoff/handoffs/{full-path-with-dashes}_{timestamp}.md
```

The full working directory path is used (with `/` replaced by `-`) to avoid collisions between projects that share the same directory name:

```
/Users/you/work/my-app  →  Users-you-work-my-app_2026-05-15_1430.md
/Users/you/side/my-app  →  Users-you-side-my-app_2026-05-15_1430.md
```

A session pointer file (`sessions/{pid}-{dir}.latest`) always tracks the most recently created handoff for the current session, so resume finds the right file even when multiple handoffs exist for the same project.

## Handoff Format

```markdown
# Handoff: Add OAuth2 login

**Generated**: 2026-05-15 14:30
**Project**: /Users/you/work/my-app
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
- Type `/clear` to start a fresh session.
- I will automatically resume from this handoff.
- Fix the refresh endpoint at src/auth/refresh.ts:42.
- Add logout: clear httpOnly cookie, POST /api/auth/logout.
```

## Configuration

### Global config

Located at `~/.claude/workspace/plugins/handoff/config.json` (auto-created with defaults on first use):

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
| `threshold` | 25 | Turns before Claude actively offers a handoff |
| `warn_at` | 21 | Turns before Claude notes it internally |
| `remind_every` | 3 | How often to remind after threshold is crossed |
| `auto_suggest` | true | Enable automatic suggestions |

### Project-level config

Override thresholds for a specific project by adding `.claude-auto-handoff.json` to the project root:

```json
{
  "threshold": 30,
  "warn_at": 25
}
```

Project config overrides global config for that directory only.

## Manual Hook Setup

The hook is registered automatically when the plugin is installed. If you need to set it up manually, add this to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c '[ -f \"${HOME}/.claude/workspace/plugins/handoff/context-monitor.sh\" ] && bash \"${HOME}/.claude/workspace/plugins/handoff/context-monitor.sh\" || true'"
          }
        ]
      }
    ]
  }
}
```

Then copy the hook script:

```bash
mkdir -p ~/.claude/workspace/plugins/handoff
cp hooks/context-monitor.sh ~/.claude/workspace/plugins/handoff/context-monitor.sh
chmod +x ~/.claude/workspace/plugins/handoff/context-monitor.sh
```

## Tips

1. **`What failed` is the most valuable section** — "Tried X, it broke because Y" saves hours in the next session.

2. **Use project-level config** — long exploratory sessions benefit from a higher threshold than focused bug fixes.

3. **For non-git projects** — everything still works, the git sections are simply omitted.

4. **Any AI can resume** — the handoff file is plain markdown. Pass the path to any AI agent and it can pick up the work.

5. **Check your handoff history** — all handoffs are in `~/.claude/workspace/plugins/handoff/handoffs/`. Run `/handoff:resume path/to/file.md` to resume from a specific one.

## License

MIT
