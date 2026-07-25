---
name: commit
description: |
  Use when committing changes or writing a commit message.
  Triggers on: "commit", "git commit", "commit changes", "write a commit message".
---

Follow Conventional Commits format:

Types: feat | fix | chore | refactor | docs | test | perf

Format: `type(scope): short imperative summary`

Rules:
- Subject line max 72 characters
- Imperative mood — "add" not "added", "fix" not "fixed"
- Scope = the feature name (auth, transfer, wallet, cards)

Examples:
- `feat(transfer): add beneficiary validation on amount input`
- `fix(wallet): correct kobo-to-naira display conversion`
- `chore(deps): upgrade riverpod to 2.6.1`

Always run `flutter analyze` before committing. Never commit with lint errors.