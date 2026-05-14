---
description: Automatically create a full handoff document from git and conversation history - no questions asked
---

Create `HANDOFF.md` without asking questions. Infer everything from git and conversation.

## Gather Context

Run (skip steps that fail if no git):
- `git status`
- `git diff --stat`
- `git log --oneline -5`

Review the conversation for: goal, what was completed, what failed, decisions made, next steps.

## Write HANDOFF.md

```markdown
# Handoff: [inferred brief title]

**Generated**: [YYYY-MM-DD HH:MM]
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
- Open a fresh Claude Code session.
- Read this handoff file first.
- [inferred from conversation]
```

After writing, say:
> "Handoff saved. Open a fresh `claude` session in this directory to auto-resume."
