---
name: implement
description: Execute one PLAN baby step in the open workspace. Validates dependencies, prepares Git branch, implements code and tests, runs build/tests, updates PLAN progress, and checkpoints context. Use when the user says "use skill implement", "implement step", "execute step", or "/implement". One session = one PLAN step; start a new chat for the next step.
---

# Skill: implement

## Trigger

Invoke when the user asks for: `use skill implement`, `implement step`, `execute step`, or `/implement`.

## Outcome

One **PLAN step** completed in the **open workspace**: code and tests for that step only, build/tests green, PLAN updated, optional commit handoff. Do not start the next PLAN step in the same session.

## Required input

| Input | Rule |
|-------|------|
| PLAN path | e.g. `PLAN/PLAN_002_feature_slug.md` |
| Step | `Step 1`, `STEP 2`, etc. (match PLAN headings) |

If missing, ask once and stop:

```
use skill implement — PLAN/PLAN_NNN_feature_slug.md — Step 1
```

## Lazy-load (only when needed)

| When | Path (after sync) |
|------|-------------------|
| .NET architecture / C# tests / checklist | `~/.cursor/skills/_shared/dotnet-guidelines/*.md` (file needed only) |
| Git orchestration | `~/.cursor/skills/_shared/developer-common/GUIDE.md` (when present) |
| Branch / commits / context | `~/.cursor/rules/branch-validation.mdc`, `conventional-commits.mdc`, `context-management.mdc` |

Do **not** preload entire `code-guidelines/` or `dotnet-guidelines/` trees.

## Process

### 0. Workspace

Confirm target repo (per PLAN), read PLAN + step block, detect stack (`*.sln` → .NET; `angular.json` → Angular), skim root `AGENTS.md` / `README.md`.

### 1. Validate step

Step exists; status **Pending** or **In progress** (redo only if user asks). All **Deps** steps **Completed**; else stop. Summarize objective, files, tests, acceptance; ask to proceed.

### 2. Git

Baseline branch from PLAN or user. Resolve dirty working tree with user. Feature branch per `branch-validation.mdc` (`feature/<slug>` or `feat/<id>`) — never `main` / `master` / `develop`. Checkout branch before edits. Open workspace only; no clone layouts or external repo APIs.

### 3. Analyze

Glob/Grep/Read step files and similar types/tests. Load dotnet-guidelines only when writing .NET code. Prefer project `docs/` over generic guidelines.

### 4. Implement

Micro-plan → implement step scope only → tests per step/AC → targeted build/test → fix within scope.

### 5. Commit (optional)

Do not commit automatically. Offer: `use skill commit`, show diff, or stop. Use `conventional-commits.mdc` + `branch-validation.mdc` when committing.

### 6. Update PLAN + checkpoint

Apply `reference.md` (repo `skills/implement/reference.md`; installed `~/.cursor/skills/implement/reference.md`): mark step **Completed**, progress bar, **Next step**, checkboxes. Save PLAN **before** `context-management.mdc` end-of-step flow (≥ 40% → pause; new chat for next step).

### 7. Report

Files, tests, `N/M` progress, next step. Handoff:

```
New chat: use skill implement — PLAN/PLAN_NNN_feature_slug.md — Step 2
```

After all steps (user-driven): `use skill code-review`, then `gh pr create` if the repo uses GitHub PRs.

## Must not

- Clone repos, `repo-mappings.json`, work-item trackers, nested `feature/base/...` branches, corporate PR templates
- Multiple PLAN steps per session; **Completed** before build/tests pass; skip PLAN save or context checkpoint
- Deprecated skill aliases in handoff — use `implement` and `commit` only
- Paste full guideline bodies into chat or PLAN

## Handoff

| Situation | Next |
|-----------|------|
| Commit | `use skill commit` |
| Next step | New session → `use skill implement — PLAN/... — Step N+1` |
| All steps done | `use skill code-review` (optional) |
