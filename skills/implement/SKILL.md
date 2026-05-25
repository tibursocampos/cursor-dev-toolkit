---
name: implement
description: Execute one PLAN baby step. Code always in English; updates PLAN .md in the file's language (pt-BR default). Use when the user says "use skill implement", "implement step", "/implement". One session = one PLAN step.
---

# Skill: implement

## Trigger

Invoke when the user asks for: `use skill implement`, `implement step`, `execute step`, or `/implement`.

## Outcome

One **PLAN step** completed: **code and tests in English** in the open workspace; PLAN updated in place (same path as input). Do not start the next step in the same session.

## Language

| Deliverable | Language |
|-------------|----------|
| Source code, tests, comments, XML docs | **English always** |
| PLAN `.md` progress, notes, checkboxes | **Same as existing PLAN file** (pt-BR default for new plans) |
| Product `docs/` or README (if step requires) | **Ask** pt-BR vs English before writing |

Do **not** re-ask SDD storage location. Do **not** change artifact language mid-PLAN unless the user requests.

## Required input

| Input | Rule |
|-------|------|
| PLAN path | e.g. `PLAN/PLAN_002_feature.md` or `~/.cursor/sdd/<repo-id>/PLAN/PLAN_002_*.md` |
| Step | `Step 1`, `PASSO 1`, etc. (match PLAN headings) |

If missing, ask once:

```
use skill implement — <full-plan-path> — Step 1
```

## Lazy-load (only when needed)

| When | Path |
|------|------|
| SDD paths / manifest | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| Artifact language scope | `~/.cursor/rules/sdd-artifact-language-pt-br.mdc` |
| .NET guidelines | `~/.cursor/skills/_shared/dotnet-guidelines/*.md` |
| Git / branch / commits | `branch-validation.mdc`, `conventional-commits.mdc`, `developer-common/GUIDE.md` |
| Context | `context-management.mdc` |

## Process

### 0. Workspace

Confirm target repo, read PLAN at **exact handoff path**, read step block, detect stack.

### 1. Validate step

Step exists; deps **Concluídos** / **Completed**; summarize objective, files, tests, acceptance; ask to proceed.

### 2. Git

Feature branch per `branch-validation.mdc`; never `main` / `master` / `develop`.

### 3. Analyze

Glob/Grep/Read step scope. Load dotnet-guidelines only when writing .NET code.

### 4. Implement

Code and tests in **English** → targeted build/test → fix within scope.

If step updates **product** `docs/` or README: ask doc language before writing.

### 5. Commit (optional)

Offer `use skill commit`; do not commit automatically.

### 6. Update PLAN + checkpoint

Apply `reference.md`: mark step **Concluído** / **Completed**, progress, **Próximo passo** / **Next step** in the PLAN file's language. Save **before** context checkpoint (≥ 40% → pause).

### 7. Report

Files, tests, `N/M` progress (pt-BR chat). Handoff:

```
New chat: use skill implement — <full-plan-path> — Step 2
```

## Must not

- Generate application code in Portuguese
- Re-ask PRD/PLAN storage or default PLAN to English on update
- Multiple PLAN steps per session; skip PLAN save
- Modify project `.gitignore` from implement

## Handoff

| Situation | Next |
|-----------|------|
| Commit | `use skill commit` |
| Next step | New session → `use skill implement — <full-plan-path> — Step N+1` |
| All steps done | `use skill code-review` (optional) |
