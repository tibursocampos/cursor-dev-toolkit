---
name: sdd-develop
description: Execute one PLAN baby step. Code always in English; updates PLAN .md in the file's language (pt-BR default). Use when the user says "use skill sdd-develop", "implement step", "/sdd-develop". One session = one PLAN step.
---

## STOP - Read before ANY tool call

1. Read `~/.cursor/rules/guardrails.mdc`
2. Read `_shared/sdd-artifacts/SESSION.md`; load session-state for `$Cwd`
3. If the relevant gate is not approved: **STOP** - ask user **(pt-BR)** - do **NOT** Write/Shell
4. SDD/develop skills: after **ONE** step/task, **STOP** session - handoff only
5. This skill body is **English**; user-facing prompts may be **(pt-BR)**

### Step -1 - Gate check (report in chat before continuing)

```
Gate check:
[ ] guardrails.mdc read
[ ] SESSION.md read; session-state loaded
[ ] PIPELINE.md read (SDD/speckit skills only)
[ ] User confirmed current action (sim)
-> If any unchecked: STOP
```

---

# Skill: sdd-develop

## Trigger

Invoke when the user asks for: `use skill sdd-develop`, `implement step`, `execute step`, or `/sdd-develop`.

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
| Caveman Mode (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` - **Full mode** |
| .NET, Git, context | `dotnet-guidelines/*.md`, `branch-validation.mdc`, `conventional-commits.mdc`, `developer-common/GUIDE.md`, `context-management.mdc` |

## Process

### -1. Pipeline, mode, and Caveman

Load `STORAGE.md` and `PIPELINE.md`. Use `STORAGE.md` schema v2 and run the dynamic storage resolution algorithm with parameter `$Workflow = classic`. Resolve `storage_mode` and `path` for the active repository. If this is the first run for the repository, execute storage mode selection and persist it in `manifest.json`.
**Agent mode** is required for code changes and PLAN updates. If the user asks for PRD (`sdd-spec`) or PLAN (`sdd-plan`), route using `PIPELINE.md` section Missing artifacts; do not create PRD/PLAN in this skill.

Check `~/.cursor/sdd/preferences.json`:
- If file missing -> create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` -> load `~/.cursor/skills/_shared/caveman/CAVEMAN.md` (Full mode rules) and display:
  > Modo Caveman ativo (respostas compactas). Digite `caveman off` a qualquer momento para desativar.
- Honor `caveman on` / `caveman off` commands at any point during the session.

### 0. Workspace

Target repo. Resolve PLAN:

| Situation | Action |
|-----------|--------|
| Canonical PLAN path given | `Read` at exact path |
| No canonical PLAN path | Glob under active storage destination; if not found, use `PIPELINE.md` section `sdd-develop` without PLAN (options 1-3) |
| User asks "criar PRD/sdd-plan" | Redirect to `sdd-spec` / `sdd-plan`; stop |

Detect stack from PLAN step.

### 1. Validate step

Step exists; deps **Concluidos** / **Completed**; summarize objective, files, tests; ask to proceed.

### 2. Git

Feature branch per `branch-validation.mdc`.

### 3-4. Analyze and implement

Glob/Grep/Read scope. Code/tests in English; targeted build/test.

### 5. Commit (optional)

Offer `use skill commit`; do not auto-commit.

### 6. Update PLAN + checkpoint

`reference.md`: mark step done, progress, next step. Save before context pause (>=40%).

### 7. Report

Files, tests, `N/M` (pt-BR). Handoff: new chat -> `use skill sdd-develop - <full-plan-path> - Step N+1`.

## Must not

- Portuguese application code; multiple steps per session
- Create PRD/PLAN; skip PLAN save; modify `.gitignore`
- Implement in Plan/Ask without Agent

## Handoff

| Situation | Next |
|-----------|------|
| Commit | `use skill commit` |
| Next step | New session -> `use skill sdd-develop - <full-plan-path> - Step N+1` |
| All steps done | `use skill code-review` (optional) |
