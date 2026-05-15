---
name: auto-handoff
description: Use when a context monitor signal appears, when HANDOFF.md exists at session start, or when user mentions handoff, resume, save state, or continuing in a new session.
---

# Auto-Handoff

## On Session Start

### 1. Auto-setup if not yet installed

Check if `~/.claude/workspace/plugins/auto-handoff/config.json` exists.

If it does NOT exist, silently run setup with defaults — no user interaction:

```bash
mkdir -p ~/.claude/workspace/plugins/auto-handoff/sessions
```

Write `~/.claude/workspace/plugins/auto-handoff/config.json`:
```json
{
  "threshold": 25,
  "warn_at": 21,
  "remind_every": 3,
  "auto_suggest": true
}
```

Then copy and install the hook script from the plugin directory to its runtime location:
```bash
cp [plugin-hooks-dir]/context-monitor.sh ~/.claude/workspace/plugins/auto-handoff/context-monitor.sh
chmod +x ~/.claude/workspace/plugins/auto-handoff/context-monitor.sh
```

Do all of this silently. Tell the user nothing unless it fails.

### 2. Check for pending resume

If `~/.claude/workspace/plugins/auto-handoff/.pending-resume` exists AND `HANDOFF.md` exists in the working directory:

- Delete the flag: `rm ~/.claude/workspace/plugins/auto-handoff/.pending-resume`
- Read `HANDOFF.md` silently
- Resume immediately without asking any questions:
  > "Resuming: [title]. Next: [first real next step after the two fixed lines]. Starting now."
- Then start working on that next step

### 3. Check for existing handoff (no pending flag)

If only `HANDOFF.md` exists (no pending-resume flag):
- Read it silently
- Say: "Found a handoff from a previous session: [goal]. Ready to resume?"
- If confirmed, start with the **Next steps** section

## On Context Monitor Signal

When you see `[CONTEXT MONITOR] Turn N (threshold: T): For optimal response quality...`:

Say naturally at the end of your current response:
> "This session is getting quite long — for optimal responses, I'd recommend a handoff to a fresh session. Want me to take care of that now?"

Rules:
- Only offer once per hook signal — the hook manages spacing (every 3 turns)
- If user says yes or any affirmative → run `/handoff` flow
- If user says no → respect it, don't ask again this session

When you see `[CONTEXT MONITOR] Turn N: This session is getting on the longer side`:
- Note internally only. Do not say anything to the user.

## Creating a Handoff (used by /handoff and /handoff:create)

1. Run `git status`, `git diff --stat`, `git log --oneline -10`, `git branch --show-current` (skip any that fail — non-git projects are fine)
2. If `HANDOFF.md` already exists, read it — carry forward any still-relevant goal, failed approaches, and warnings
3. Infer everything from conversation + git — do not ask the user any questions
4. Write `HANDOFF.md` using the format below
5. Write the resume flag: `touch ~/.claude/workspace/plugins/auto-handoff/.pending-resume`
6. Say: "Handoff created. Clearing session and resuming..."
7. Run `/clear`
8. After clear: read `HANDOFF.md` silently, then resume immediately — say "Resuming: [title]. Next: [first real next step]." and start working

## HANDOFF.md Format

```markdown
# Handoff: [brief title]

**Generated**: [YYYY-MM-DD HH:MM]
**Branch**: [branch name or "no git"]
**Status**: [In Progress / Blocked / Ready for Review]

## Goal
- [what we're trying to achieve]

## Current state
- [what's working / built right now]

## Files touched
- path/to/file.ts
- path/to/other.tsx

## What changed
- [brief description of each meaningful change]

## What failed
- [what was tried and abandoned — be specific, or "None"]

## Next steps
- Open a fresh Claude Code session.
- Read this handoff file first.
- [specific next step]
```

**Non-negotiable rules:**
- `Next steps` ALWAYS starts with those two fixed lines
- `What failed` is NEVER omitted — write "None" if nothing failed
- File paths are relative to repo root
- If a previous HANDOFF.md existed, merge still-relevant context (goals, failures, warnings)

## Trigger Words

Also activate when user says: "handoff", "hand off", "save state", "continue later",
"pick up where", "transfer context", "resume", "new session", "take over"
