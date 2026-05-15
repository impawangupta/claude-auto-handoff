---
name: auto-handoff
description: Use when a context monitor signal appears, when a handoff exists for this project, or when user mentions handoff, resume, save state, or continuing in a new session.
---

# Auto-Handoff

## Paths

```
PLUGIN_DIR   = ~/.claude/workspace/plugins/handoff
HANDOFFS_DIR = ~/.claude/workspace/plugins/handoff/handoffs
SESSIONS_DIR = ~/.claude/workspace/plugins/handoff/sessions
CONFIG       = ~/.claude/workspace/plugins/handoff/config.json
RESUME_FLAG  = ~/.claude/workspace/plugins/handoff/.pending-resume
```

### Handoff filename convention

Use the full working directory path with `/` replaced by `-` (strip the leading `-`), plus timestamp:

```bash
DIR_KEY=$(echo "$PWD" | tr '/' '-' | sed 's/^-//')
# /Users/themagician/ai/myapp -> Users-themagician-ai-myapp
HANDOFF_FILE="${HOME}/.claude/workspace/plugins/handoff/handoffs/${DIR_KEY}_$(date +%Y-%m-%d_%H%M).md"
```

### Session pointer

When a handoff is created, write its path to a session pointer so resume always knows the latest:

```bash
DIR_SAFE=$(echo "$PWD" | tr '/' '_' | cut -c1-80)
SESSION_POINTER="${HOME}/.claude/workspace/plugins/handoff/sessions/${PPID}-${DIR_SAFE}.latest"
echo "$HANDOFF_FILE" > "$SESSION_POINTER"
```

On resume, read the pointer first. Fall back to newest file matching the prefix if pointer is absent.

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

1. Delete the flag: `rm ~/.claude/workspace/plugins/handoff/.pending-resume`
2. Find the latest handoff for this session via the pointer file:
   ```bash
   DIR_SAFE=$(echo "$PWD" | tr '/' '_' | cut -c1-80)
   SESSION_POINTER="${HOME}/.claude/workspace/plugins/handoff/sessions/${PPID}-${DIR_SAFE}.latest"
   ```
   If pointer exists, read the path inside it. Otherwise fall back to newest file matching `${DIR_KEY}_*`:
   ```bash
   DIR_KEY=$(echo "$PWD" | tr '/' '-' | sed 's/^-//')
   ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^${DIR_KEY}_" | head -1
   ```
3. Read the handoff silently
4. Resume immediately without asking:
   > "Resuming: [title]. Next: [first real next step]. Starting now."
5. Start working

### 3. Check for existing handoff (no pending flag)

Find the latest handoff for this project:
```bash
DIR_KEY=$(echo "$PWD" | tr '/' '-' | sed 's/^-//')
ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^${DIR_KEY}_" | head -1
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
- If user says yes → run the handoff creation flow below
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

2. Build the file path:
   ```bash
   DIR_KEY=$(echo "$PWD" | tr '/' '-' | sed 's/^-//')
   HANDOFF_FILE="${HOME}/.claude/workspace/plugins/handoff/handoffs/${DIR_KEY}_$(date +%Y-%m-%d_%H%M).md"
   ```

3. Check for an existing handoff — carry forward still-relevant goal, failures, and warnings from previous handoffs for this project.

4. Infer everything from conversation + git. Do not ask the user any questions.

5. Write the handoff document (format below).

6. Write the session pointer:
   ```bash
   DIR_SAFE=$(echo "$PWD" | tr '/' '_' | cut -c1-80)
   SESSION_POINTER="${HOME}/.claude/workspace/plugins/handoff/sessions/${PPID}-${DIR_SAFE}.latest"
   echo "$HANDOFF_FILE" > "$SESSION_POINTER"
   ```

7. Set the resume flag:
   ```bash
   touch ~/.claude/workspace/plugins/handoff/.pending-resume
   ```

8. Tell the user:
   > "Handoff saved. Type `/clear` to start fresh — I'll automatically pick up where we left off."

Note: `/clear` must be typed by the user — Claude Code slash commands cannot be triggered programmatically.

## HANDOFF.md Format

```markdown
# Handoff: [brief title]

**Generated**: [YYYY-MM-DD HH:MM]
**Project**: [full working directory path]
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
