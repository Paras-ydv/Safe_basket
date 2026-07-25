---
name: sprint-status
description: |
  Use when asked about current status, what's left to do, or what changed.
---

## Current git status
!`git status --short`

## Uncommitted changes
!`git diff --stat HEAD`

## Recent commits
!`git log --oneline -10`

## Lint status
!`flutter analyze 2>&1 | tail -20`

Review the above and give a concise summary of: what's done, what's broken, and what needs attention before the next commit.