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

Check for an existing handoff for this project:
```bash
ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^$(basename "$PWD")_" | head -1
```

If found, read it and carry forward still-relevant context.

## Determine File Path

```bash
HANDOFF_FILE="${HOME}/.claude/workspace/plugins/handoff/handoffs/$(basename "$PWD")_$(date +%Y-%m-%d_%H%M).md"
```

## Write the Handoff Document

```markdown
# Handoff: [inferred brief title]

**Generated**: [YYYY-MM-DD HH:MM]
**Project**: [basename of current directory]
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

After writing, say:
> "Handoff saved to `~/.claude/workspace/plugins/handoff/handoffs/[filename]`. Type `/clear` to start fresh — I'll automatically resume."
