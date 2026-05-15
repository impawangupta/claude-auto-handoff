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

Check for an existing handoff for this project:
```bash
ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^$(basename "$PWD")_" | head -1
```

If found, read it — carry forward still-relevant goal, failed approaches, and warnings.

## Step 2: Infer Everything from the Conversation

From the full conversation history, extract without asking:
- **Goal**: what the user is trying to accomplish (merge with previous handoff goal if still relevant)
- **Current state**: what is working right now
- **Files touched**: from git diff or files mentioned and edited in conversation
- **What changed**: meaningful changes made this session and any prior sessions
- **What failed**: anything tried and abandoned — carry forward from previous handoff if still applicable
- **Next steps**: logical next actions based on what remains

## Step 3: Determine File Path

```bash
HANDOFF_FILE="${HOME}/.claude/workspace/plugins/handoff/handoffs/$(basename "$PWD")_$(date +%Y-%m-%d_%H%M).md"
```

## Step 4: Write the Handoff Document

```markdown
# Handoff: [inferred title]

**Generated**: [YYYY-MM-DD HH:MM]
**Project**: [basename of current directory]
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

## Step 5: Set Resume Flag

```bash
touch ~/.claude/workspace/plugins/handoff/.pending-resume
```

## Step 6: Tell the User

Say:
> "Handoff saved to `~/.claude/workspace/plugins/handoff/handoffs/[filename]`. Type `/clear` to start fresh — I'll automatically pick up where we left off."

Note: `/clear` must be typed by the user — Claude Code slash commands cannot be triggered programmatically. The pending-resume flag ensures auto-resume happens on the very next interaction after clear.
