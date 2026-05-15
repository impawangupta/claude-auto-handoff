---
description: Resume work from an existing HANDOFF.md - reads it, checks for state drift, and continues immediately without asking questions
---

Resume from a handoff. Do not ask the user if they want to resume — just do it.

## 1. Find the Handoff

- If `$ARGUMENTS` is provided, read that path
- Otherwise check for `HANDOFF.md` in the current directory
- If not found, say: "No HANDOFF.md found. Pass a path with `/handoff:resume path/to/HANDOFF.md`"

## 2. Check for State Drift

Run `git status` and `git log --oneline -3`. If branch or state has changed significantly, note it briefly without asking:
> "Note: the repo has changed since this handoff — [brief description]. Continuing with handoff context."

## 3. Resume Immediately

Say:
```
Resuming: [title]
Goal: [one sentence]
Next: [first real step after the two fixed lines]
```

Then start working on that next step without waiting for confirmation.

Always respect:
- **What failed** — do not repeat those approaches
- **Goal** — don't drift scope
