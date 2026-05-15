---
description: Resume from the latest handoff for this session or project - reads it and continues immediately without asking questions
---

Resume from the most relevant handoff. Do not ask the user if they want to resume — just do it.

## 1. Find the Handoff

If `$ARGUMENTS` is provided, read that path directly.

Otherwise, find via session pointer first (most precise — handles multiple handoffs per session):
```bash
DIR_SAFE=$(echo "$PWD" | tr '/' '_' | cut -c1-80)
SESSION_POINTER="${HOME}/.claude/workspace/plugins/handoff/sessions/${PPID}-${DIR_SAFE}.latest"
cat "$SESSION_POINTER" 2>/dev/null
```

If the pointer file doesn't exist or the file it points to is missing, fall back to newest file matching this project's full-path prefix:
```bash
DIR_KEY=$(echo "$PWD" | tr '/' '-' | sed 's/^-//')
ls -t ~/.claude/workspace/plugins/handoff/handoffs/ | grep "^${DIR_KEY}_" | head -1
```

If nothing found, say: "No handoff found for this project. Run `/handoff` to create one."

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
