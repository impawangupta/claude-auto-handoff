---
description: Create a minimal handoff - just the essentials, fast
---

Create a minimal handoff document. Run `git status` and `git diff --stat` silently first.

## File Path

```bash
HANDOFF_FILE="${HOME}/.claude/workspace/plugins/handoff/handoffs/$(basename "$PWD")_$(date +%Y-%m-%d_%H%M).md"
```

## Write

```markdown
# Handoff: [task in 5 words or less]

**Generated**: [YYYY-MM-DD HH:MM]
**Project**: [basename of current directory]

## Goal
- [one sentence]

## Current state
- [one or two bullets on what's working right now]

## What failed
- [one bullet, or "None"]

## Next steps
- Type `/clear` to start a fresh session.
- I will automatically resume from this handoff.
- [the single most important next step]
```

After writing, say:
> "Quick handoff saved. Type `/clear` to start fresh — I'll automatically resume."
