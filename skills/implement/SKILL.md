---
name: implement
description: Execute one PLAN baby step. Code always in English; updates PLAN .md in the file's language (pt-BR default). Use when the user says "use skill implement", "implement step", "/implement". One session = one PLAN step.
---

# Skill: implement

## Trigger

Invoke when the user asks for: `use skill implement`, `implement step`, `execute step`, or `/implement`.

## Outcome

One **PLAN step** done: **code and tests in English**; PLAN updated in place. Do not start the next step in the same session.

## Language

| Deliverable | Language |
|-------------|----------|
| Code, tests, comments, XML docs | **English** |
| PLAN progress / notes | **Same as PLAN file** |
| Product `docs/` / README | Ask pt-BR vs English first |

Do not re-ask SDD storage or change artifact language mid-PLAN unless requested.

## Required input

| Input | Rule |
|-------|------|
| PLAN path | Canonical: `PLAN/PLAN_NNN_*.md` or `~/.cursor/sdd/<repo-id>/PLAN/PLAN_NNN_*.md` |
| Step | `Step 1`, `PASSO 1`, etc. |

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Pipeline, missing PLAN dialog | `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md` |
| Storage | `STORAGE.md` |
| .NET, Git, context | `dotnet-guidelines/*.md`, `branch-validation.mdc`, `conventional-commits.mdc`, `developer-common/GUIDE.md`, `context-management.mdc` |

## Process

### -1. Pipeline and mode

Load `PIPELINE.md`. **Agent** required for code changes and PLAN updates. If user asks for PRD/`spec` or PLAN/`plan` → guide per § Missing artifacts; do not create PRD/PLAN here.

### 0. Workspace

Target repo. Resolve PLAN:

| Situation | Action |
|-----------|--------|
| Canonical PLAN path given | `Read` at exact path |
| No canonical PLAN | `PIPELINE.md` § `implement` without PLAN (options 1–3) |
| User asks “criar PRD/plan” | Redirect to `spec` / `plan`; stop |

Detect stack from PLAN step.

### 1. Validate step

Step exists; deps **Concluídos** / **Completed**; summarize objective, files, tests; ask to proceed.

### 2. Git

Feature branch per `branch-validation.mdc`.

### 3–4. Analyze and implement

Glob/Grep/Read scope. Code/tests in English; targeted build/test.

### 5. Commit (optional)

Offer `use skill commit`; do not auto-commit.

### 6. Update PLAN + checkpoint

`reference.md`: mark step done, progress, next step. Save before context pause (≥40%).

### 7. Report

Files, tests, `N/M` (pt-BR). Handoff: new chat → `use skill implement — <full-plan-path> — Step N+1`.

## Must not

- Portuguese application code; multiple steps per session
- Create PRD/PLAN; skip PLAN save; modify `.gitignore`
- Implement in Plan/Ask without Agent

## Handoff

| Situation | Next |
|-----------|------|
| Commit | `use skill commit` |
| Next step | New session → `implement — <plan> — Step N+1` |
| All steps done | `use skill code-review` (optional) |
