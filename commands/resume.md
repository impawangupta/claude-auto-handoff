---
description: Resume work from the most recent handoff for this project - reads it and continues immediately without asking questions
---

Resume from the most recent handoff for this project. Do not ask the user if they want to resume — just do it.

## 1. Find the Handoff

If `$ARGUMENTS` is provided, read that path directly.

Otherwise find the most recent handoff for this project:
```bash
ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^$(basename "$PWD")_" | head -1
```

If none found, say: "No handoff found for this project. Run `/handoff` to create one."

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
