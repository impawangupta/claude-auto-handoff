---
description: Guided handoff - Claude gathers git context then asks you key questions one at a time before writing HANDOFF.md
---

Run a guided handoff. Gather context silently first, then ask one question at a time.

## Step 1: Gather Context Silently

Run (skip steps that fail if no git):
- `git status`
- `git diff --stat`
- `git log --oneline -5`

Note: files touched, current branch, what changed. Do not show output to the user yet.

## Step 2: Ask One Question at a Time

Ask each question and wait for the answer before continuing:

1. "What was the main goal of this session?"
2. "What did we get done?"
3. "Anything we tried that didn't work — that the next session should avoid?"
4. "What are the specific next steps to continue from here?"
5. "Any warnings or gotchas the next session should know about?"

## Step 3: Write HANDOFF.md

Combine git context with user answers:

```markdown
# Handoff: [title from goal]

**Generated**: [YYYY-MM-DD HH:MM]
**Branch**: [branch or "no git"]
**Status**: [In Progress / Blocked / Ready for Review]

## Goal
- [from user answer]

## Current state
- [from git + user answer on what's done]

## Files touched
- [from git diff --stat — relative paths]

## What changed
- [from git log + conversation]

## What failed
- [from user answer, or "None"]

## Next steps
- Open a fresh Claude Code session.
- Read this handoff file first.
- [from user answer]
```

## Step 4: Confirm

Say:
> "Handoff saved to `HANDOFF.md`. Open a fresh `claude` session in this directory — I'll automatically pick up where we left off."
