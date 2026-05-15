---
description: Automatically generate a handoff document from the current conversation and git context, then prompt the user to /clear for a fresh session - no questions asked
---

Generate a handoff document automatically. Do not ask the user any questions.

## Step 1: Gather All Context

Run silently (skip any that fail):
```bash
git branch --show-current
git status
git diff --stat
git log --oneline -10
```

## Step 2: Build the File Path

```bash
DIR_KEY=$(echo "$PWD" | tr '/' '-' | sed 's/^-//')
HANDOFF_FILE="${HOME}/.claude/workspace/plugins/handoff/handoffs/${DIR_KEY}_$(date +%Y-%m-%d_%H%M).md"
```

Example: `/Users/themagician/ai/myapp` → `Users-themagician-ai-myapp_2026-05-15_1430.md`

## Step 3: Check for Previous Handoffs

Find the most recent existing handoff for this project:
```bash
ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^${DIR_KEY}_" | head -1
```

If found, read it — carry forward still-relevant goal, failed approaches, and warnings.

## Step 4: Infer Everything from the Conversation

From the full conversation history, extract without asking:
- **Goal**: what the user is trying to accomplish (merge with previous handoff goal if still relevant)
- **Current state**: what is working right now
- **Files touched**: from git diff or files mentioned and edited in conversation
- **What changed**: meaningful changes made this session
- **What failed**: anything tried and abandoned — carry forward from previous handoff if still applicable
- **Next steps**: logical next actions based on what remains

## Step 5: Write the Handoff Document

```markdown
# Handoff: [inferred title]

**Generated**: [YYYY-MM-DD HH:MM]
**Project**: [full $PWD path]
**Branch**: [branch or "no git"]
**Status**: [In Progress / Blocked / Ready for Review]

## Goal
- [inferred from conversation]

## Current state
- [what is working right now]

## Files touched
- [from git diff --stat — relative paths]

## What changed
- [meaningful changes this session]

## What failed
- [what was tried and abandoned, or "None"]

## Next steps
- Type `/clear` to start a fresh session.
- I will automatically resume from this handoff.
- [inferred next steps]
```

## Step 6: Write the Session Pointer

This file lets resume always find the latest handoff for this session, even if multiple were created:

```bash
DIR_SAFE=$(echo "$PWD" | tr '/' '_' | cut -c1-80)
SESSION_POINTER="${HOME}/.claude/workspace/plugins/handoff/sessions/${PPID}-${DIR_SAFE}.latest"
echo "$HANDOFF_FILE" > "$SESSION_POINTER"
```

## Step 7: Set Resume Flag

```bash
touch ~/.claude/workspace/plugins/handoff/.pending-resume
```

## Step 8: Tell the User

Say:
> "Handoff saved. Type `/clear` to start fresh — I'll automatically pick up where we left off."
