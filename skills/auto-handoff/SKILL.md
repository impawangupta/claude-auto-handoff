---
name: auto-handoff
description: Use when a context monitor signal appears, when HANDOFF.md exists at session start, or when user mentions handoff, resume, save state, or continuing in a new session.
---

# Auto-Handoff

## On Session Start

Check if `HANDOFF.md` exists in the working directory. If found:
1. Read it silently
2. Say: "Found a handoff from a previous session: [goal in one sentence]. Ready to resume?"
3. If confirmed, start with the **Next steps** section of the handoff

## On Context Monitor Signal

When you see `[CONTEXT MONITOR] Turn N (threshold: T): For optimal response quality...`:

Offer a handoff naturally in the conversation:
> "This session is getting quite long — for optimal responses, I'd recommend handing off to a fresh session. Context length can affect the quality of my answers. Want me to create a handoff document so we can continue seamlessly?"

Rules:
- Only offer once — the hook controls reminder frequency (every 3 turns)
- If user says yes or any affirmative → follow **Creating a Handoff** below
- If user says no → respect it, stop asking for this session
- If user says "not yet" → wait for the next hook signal

When you see `[CONTEXT MONITOR] Turn N: This session is getting on the longer side`:
- Note internally only. Do not interrupt the user.

## Creating a Handoff

1. Run `git status`, `git diff --stat`, `git log --oneline -5` (skip if no git)
2. Gather goal, progress, failures, and next steps from the conversation
3. Write `HANDOFF.md` using the format below
4. Say: "Done — open a fresh `claude` session in this directory and I'll automatically pick up where we left off."

## HANDOFF.md Format

```markdown
# Handoff: [brief title]

**Generated**: [YYYY-MM-DD HH:MM]
**Branch**: [branch name or "no git"]
**Status**: [In Progress / Blocked / Ready for Review]

## Goal
- [what we're trying to achieve — bullet points]

## Current state
- [what's working / built / approved right now]

## Files touched
- path/to/changed/file.ts
- path/to/another/file.tsx

## What changed
- [brief description of each meaningful change this session]

## What failed
- [what was tried but didn't work — be specific, or "None"]

## Next steps
- Open a fresh Claude Code session.
- Read this handoff file first.
- [specific next step]
- [specific next step]
```

**Non-negotiable rules:**
- `Next steps` ALWAYS starts with those two fixed lines — no exceptions
- `What failed` is NEVER omitted — write "None" if nothing failed
- File paths are relative to repo root
- Bullets are concise — every word earns its place

## Trigger Words

Also activate when user says: "handoff", "hand off", "pass this", "continue later",
"pick up where", "save state", "transfer context", "resume", "new session", "take over"
