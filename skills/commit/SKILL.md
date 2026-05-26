---
name: commit
description: Review staged and unstaged changes, draft a Conventional Commits message, commit on a valid feature branch, and optionally push. Use when the user says "use skill commit", "commit changes", or "/commit". Git-only — no work-item tracker APIs.
---

# Skill: commit

## Trigger

Invoke when the user asks for: `use skill commit`, `commit changes`, or `/commit`.

## Outcome

One or more **Conventional Commits** on `feature/<slug>` or `feat/<id>`, with an optional push. No automatic commit without user approval of the message.

## Lazy-load (only when needed)

| When | Path (after `scripts/sync-cursor.ps1`) |
|------|----------------------------------------|
| Branch rules | `~/.cursor/rules/branch-validation.mdc` |
| Commit format | `~/.cursor/rules/conventional-commits.mdc` |
| Detailed Git flow | `~/.cursor/skills/_shared/developer-common/step-4-commits-pr.md` |
| Pre-commit checks | `~/.cursor/skills/_shared/developer-common/step-3.5-precommit-validation.md` |
| Message validator (ETAPA 11+) | `~/.cursor/skills/_shared/format-validators/commit-message-validator.md` |

## Process

### 0. Workspace

Confirm the **target repository** (not `cursor-dev-toolkit` unless that is the project). Read `AGENTS.md` / `README.md` if present.

### 1. Validate branch (blocker)

Before any `git add`, `git commit`, or `git push`, enforce `branch-validation.mdc`:

- Allowed: `feature/<slug>`, `feat/<id>` (single segment after prefix)
- Blocked: `main`, `master`, `develop`, nested `feature/a/b`, or any other pattern

If blocked, stop and show how to create a valid branch. Do not stage or commit.

### 2. Inspect changes

Run in parallel:

```bash
git status
git diff --staged
git diff
git log --oneline -10
```

If the working tree is clean and there is nothing to commit, report and stop.

Summarize: files changed, nature (feat/fix/refactor/test/docs), scope, breaking changes.

### 3. Pre-commit validation

Follow `step-3.5-precommit-validation.md` when changes are non-trivial (secrets scan, build/quick test per stack). User may skip with explicit acknowledgment.

### 4. Draft commit message

Apply `conventional-commits.mdc` and `step-4-commits-pr.md`:

```
<type>[optional scope][!]: <description>

[optional body — why, not what]

Refs: #<issue>    # optional footer
```

Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

Present the proposed message and **wait for user confirmation** before committing. Apply edits if requested.

Prefer **atomic commits**: stage explicit paths — avoid `git add -A` unless the user explicitly requests it.

### 5. Commit

After approval:

```bash
git add <explicit paths>
git commit -m "$(cat <<'EOF'
<message>
EOF
)"
```

Use **only** `-m` (or `-F` with a message file the user approved). Do **not** add `--trailer`, `--author` overrides, or extra `-m` blocks for attribution.

Do not use `git commit --amend` on shared or pushed history unless the user explicitly requests it and amend rules apply.

### 6. Push (optional)

Push only when the user asks:

```bash
git push -u origin HEAD
```

Never `git push --force` to `main`, `master`, or `develop`.

### 7. Report

- Branch name
- Short commit hash (`git rev-parse --short HEAD`)
- Files included
- Push status (if applicable)
- SDD handoff: if mid-PLAN, remind to update PLAN via `implement` before the next step in a new chat

## Must not

- Commit on `main`, `master`, `develop`, or invalid branch names
- ADO/MCP work-item APIs, mandatory PR creation, or corporate PR templates
- `git add -A` / `git add .` without review (unless user explicitly requests)
- Deprecated commit skill aliases in user-facing handoff — use `commit` only
- Auto-commit without message approval
- **Cursor co-author trailers** — forbidden in any form:
  - `Co-authored-by: Cursor …` (or similar) in the message body or footers
  - `git commit --trailer "Co-authored-by: …"` / `--trailer=Co-authored-by:…`
  - Any flag or footer that attributes Cursor as co-author of the commit

## Handoff

| Situation | Next |
|-----------|------|
| Continue SDD step | New session → `use skill implement — <full-plan-path> — Step N` |
| Review before PR | `use skill code-review` |
| Create PR (user asks) | `gh pr create` per `step-4-commits-pr.md` |
