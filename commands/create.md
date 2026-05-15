---
description: Automatically create a handoff document from git and conversation history and save it to the workspace - no questions asked
---

Create a handoff document without asking questions. Infer everything from git and conversation.

## Gather Context

Run silently (skip any that fail):
```bash
git branch --show-current
git status
git diff --stat
git log --oneline -5
```

## Build the File Path

```bash
DIR_KEY=$(echo "$PWD" | tr '/' '-' | sed 's/^-//')
HANDOFF_FILE="${HOME}/.claude/workspace/plugins/handoff/handoffs/${DIR_KEY}_$(date +%Y-%m-%d_%H%M).md"
```

## Check for Previous Handoffs

```bash
ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^${DIR_KEY}_" | head -1
```

If found, read it and carry forward still-relevant context.

## Write the Handoff Document

```markdown
# Handoff: [inferred brief title]

**Generated**: [YYYY-MM-DD HH:MM]
**Project**: [full $PWD path]
**Branch**: [branch or "no git"]
**Status**: [In Progress / Blocked / Ready for Review]

## Goal
- [inferred from conversation]

## Current state
- [inferred from conversation + git status]

## Files touched
- [from git diff --stat — relative paths]

## What changed
- [from git log + conversation]

## What failed
- [from conversation, or "None"]

## Next steps
- Type `/clear` to start a fresh session.
- I will automatically resume from this handoff.
- [inferred from conversation]
```

## Write the Session Pointer

```bash
DIR_SAFE=$(echo "$PWD" | tr '/' '_' | cut -c1-80)
SESSION_POINTER="${HOME}/.claude/workspace/plugins/handoff/sessions/${PPID}-${DIR_SAFE}.latest"
echo "$HANDOFF_FILE" > "$SESSION_POINTER"
```

After writing, say:
> "Handoff saved to `[HANDOFF_FILE]`. Type `/clear` to start fresh — I'll automatically resume."
