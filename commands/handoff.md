---
description: Automatically generate a handoff document from the current conversation and git context, clear the session, and resume immediately - no questions asked
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

If `HANDOFF.md` already exists in the working directory, read it — carry forward any still-relevant goal, failed approaches, and warnings from previous sessions.

## Step 2: Infer Everything from the Conversation

From the full conversation history, extract without asking:
- **Goal**: what the user is trying to accomplish
- **Current state**: what is working right now
- **Files touched**: from git diff or files mentioned and edited in conversation
- **What changed**: meaningful changes made this session
- **What failed**: anything tried and abandoned — carry forward from previous handoff if still applicable
- **Next steps**: logical next actions based on what remains

## Step 3: Write HANDOFF.md

```markdown
# Handoff: [inferred title]

**Generated**: [YYYY-MM-DD HH:MM]
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
- Open a fresh Claude Code session.
- Read this handoff file first.
- [inferred next steps]
```

## Step 4: Set Resume Flag

```bash
touch ~/.claude/workspace/plugins/auto-handoff/.pending-resume
```

## Step 5: Clear and Resume

1. Say: "Handoff created. Clearing session and resuming..."
2. Run `/clear`
3. After clear, read `HANDOFF.md` silently
4. Immediately resume: say "Resuming: [title]. Next: [first real next step]." then start working
