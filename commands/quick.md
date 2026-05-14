---
description: Create a minimal handoff - just the essentials, fast
---

Create a minimal `HANDOFF.md`. Run `git status` and `git diff --stat` silently first, then write:

```markdown
# Handoff: [task in 5 words or less]

## Goal
- [one sentence]

## Current state
- [one or two bullets on what's working right now]

## What failed
- [one bullet, or "None"]

## Next steps
- Open a fresh Claude Code session.
- Read this handoff file first.
- [the single most important next step]
```

Save to `HANDOFF.md`, or to the path in `$ARGUMENTS` if provided.

After writing, say:
> "Quick handoff saved. Open a fresh `claude` session to continue."
