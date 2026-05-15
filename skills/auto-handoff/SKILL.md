---
name: auto-handoff
description: Use when a context monitor signal appears, when a handoff exists for this project, or when user mentions handoff, resume, save state, or continuing in a new session.
---

# Auto-Handoff

## Paths

```
PLUGIN_DIR  = ~/.claude/workspace/plugins/handoff
HANDOFFS    = ~/.claude/workspace/plugins/handoff/handoffs
CONFIG      = ~/.claude/workspace/plugins/handoff/config.json
RESUME_FLAG = ~/.claude/workspace/plugins/handoff/.pending-resume
```

Handoff files are named: `{project-basename}_{YYYY-MM-DD_HHMM}.md`
Example: `my-app_2026-05-15_1430.md`

## On Session Start

### 1. Auto-setup if not yet installed

Check if `~/.claude/workspace/plugins/handoff/config.json` exists. If not, silently run:

```bash
mkdir -p ~/.claude/workspace/plugins/handoff/handoffs
mkdir -p ~/.claude/workspace/plugins/handoff/sessions
```

Write `~/.claude/workspace/plugins/handoff/config.json`:
```json
{
  "threshold": 25,
  "warn_at": 21,
  "remind_every": 3,
  "auto_suggest": true
}
```

Copy the hook script:
```bash
cp [plugin-hooks-dir]/context-monitor.sh ~/.claude/workspace/plugins/handoff/context-monitor.sh
chmod +x ~/.claude/workspace/plugins/handoff/context-monitor.sh
```

Do all of this silently. Tell the user nothing.

### 2. Check for pending resume

If `~/.claude/workspace/plugins/handoff/.pending-resume` exists:
- Delete the flag: `rm ~/.claude/workspace/plugins/handoff/.pending-resume`
- Find the most recent handoff for this project:
  ```bash
  ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^$(basename "$PWD")_" | head -1
  ```
- Read it silently
- Resume immediately without asking any questions:
  > "Resuming: [title]. Next: [first real next step]. Starting now."
- Then start working

### 3. Check for existing handoff (no pending flag)

Find the most recent handoff for the current project directory:
```bash
ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^$(basename "$PWD")_" | head -1
```

If found:
- Read it silently
- Say: "Found a handoff from a previous session: [goal]. Ready to resume?"
- If confirmed, start with the **Next steps** section

## On Context Monitor Signal

When you see `[CONTEXT MONITOR] Turn N (threshold: T): For optimal response quality...`:

Say at the end of your current response:
> "This session is getting quite long — for optimal responses, I'd recommend a handoff to a fresh session. Want me to take care of that now?"

- Only offer once per hook signal
- If user says yes → run the handoff flow below
- If user says no → respect it, don't ask again this session

When you see `[CONTEXT MONITOR] Turn N: This session is getting on the longer side`:
- Note internally only. Say nothing to the user.

## Creating a Handoff

1. Run silently (skip any that fail):
   ```bash
   git branch --show-current
   git status
   git diff --stat
   git log --oneline -10
   ```
2. Check for an existing handoff for this project — carry forward still-relevant goal, failures, and warnings
3. Infer everything from conversation + git. Do not ask the user any questions.
4. Determine the handoff file path:
   ```bash
   HANDOFF_FILE="${HOME}/.claude/workspace/plugins/handoff/handoffs/$(basename "$PWD")_$(date +%Y-%m-%d_%H%M).md"
   ```
5. Write the handoff document to that path (see format below)
6. Set the resume flag:
   ```bash
   touch ~/.claude/workspace/plugins/handoff/.pending-resume
   ```
7. Tell the user:
   > "Handoff saved. Type `/clear` to start fresh — I'll automatically pick up where we left off."

Note: Claude Code slash commands cannot be triggered programmatically. The user must type `/clear` themselves. The pending-resume flag ensures auto-resume happens on the next interaction after clear.

## HANDOFF.md Format

```markdown
# Handoff: [brief title]

**Generated**: [YYYY-MM-DD HH:MM]
**Project**: [basename of working directory]
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
- Type `/clear` to start a fresh session.
- I will automatically resume from this handoff.
- [specific next step]
- [specific next step]
```

**Rules:**
- `Next steps` always starts with those two fixed lines
- `What failed` is never omitted — write "None" if nothing failed
- File paths are relative to repo root
- Merge context from previous handoffs if they exist for this project

## Trigger Words

Also activate when user says: "handoff", "hand off", "save state", "continue later",
"pick up where", "transfer context", "resume", "new session", "take over"
