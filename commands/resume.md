---
description: Resume work from a handoff document - reads HANDOFF.md, checks for state drift, and continues from Next steps
---

Resume from a handoff created in a previous session.

## 1. Find the Handoff

- If `$ARGUMENTS` is provided, read that path
- Otherwise check for `HANDOFF.md` in the current directory
- If not found, ask the user for the path

## 2. Check for State Drift

Run `git status` and `git log --oneline -3`. Compare with the handoff's **Branch** and **Current state**:
- Branch changed? Warn: "The repo has changed since this handoff was created. [describe changes]. Continue anyway?"
- New commits since the handoff? Say: "There have been N commits since this handoff was created."
- No git? Skip this step.

## 3. Summarize

Give a brief summary — not the whole document:

```
Resuming: [title]
Goal: [one sentence from ## Goal]
Next: [first real step after the two fixed lines in ## Next steps]
Ready to continue?
```

## 4. Begin Work

Start with the first real next step (the one after "Open a fresh Claude Code session." and "Read this handoff file first.").

Always respect:
- **What failed** — do not repeat those approaches
- **Goal** — don't drift scope without checking with the user
- **Warnings** in Next steps or What failed

If anything critical is unclear, ask rather than guess.
