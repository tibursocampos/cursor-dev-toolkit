---
name: plan
description: Create a baby-step PLAN from an existing PRD. Writes agent PLAN .md in pt-BR by default (repo or ~/.cursor/sdd/<repo-id>/). Use when the user says "use skill plan", "create plan", "/plan". Requires a PRD; output feeds implement.
---

# Skill: plan

## Trigger

Invoke when the user asks for: `use skill plan`, `create plan`, `execution plan`, or `/plan`.

## Outcome

A **PLAN** in **pt-BR** at a **canonical** path (`PLAN/PLAN_NNN_*.md` or global). Same `NNN` as PRD. Each step = one `implement` session. Paths and test names in **English**; no code blocks.

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Pipeline guards, missing PRD dialog | `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md` |
| Storage, manifest, `.gitignore` | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| SDD language, context, .NET | `sdd-artifact-language-pt-br.mdc`, `context-management.mdc`, `dotnet-guidelines/*.md` |

## Process

### -1. Pipeline and mode

Load `PIPELINE.md`. Phase A/B as for `spec`. No PRD authoring; no production/test code.

### 0. Workspace

Target repo. Read `AGENTS.md` / `README.md` if present.

### 1. Resolve PRD

Glob canonical PRDs (workspace + `~/.cursor/sdd/<repo-id>/PRD/`).

| Situation | Action |
|-----------|--------|
| User gave canonical PRD path | `Read`; validate status **Pronto para planejamento** / **Ready for planning** |
| No canonical PRD | `PIPELINE.md` § `plan` without PRD — options 1 or 2; then collect text or file path |
| “Criar PRD” | Choice **1** → hand off to `spec` inputs; do not write PLAN until PRD exists (unless user chose **2**) |
| Non-canonical `.md` | Promote per `PIPELINE.md` or ask for file |

Summarize PRD; ask to proceed.

### 2–4. Explore, technical questions (≤10), baby steps

Glob/Grep/Read. Steps ~20–45 min each. Doc-update steps: **implement** asks doc language.

### 5. Context checkpoint

`context-management.mdc`; PLAN draft in chat if ≥40%.

### 5.5 PLAN storage

`STORAGE.md`; global PLAN if PRD is global; else manifest or prompt.

### 5.75 Confirm before write

`PIPELINE.md` § Confirm before write — `PLAN_NNN_*`, full path, PRD link, step count. **sim** required before `Write` in Agent.

### 6. Write PLAN (Agent + sim only)

1. Validate canonical PLAN path; `NNN` **equals** PRD `NNN`.
2. Repository mode: `.gitignore` per `STORAGE.md`.
3. Template `reference.md`; PRD header = full PRD path; steps **Pendente**; `0/N`.
4. Warn if overwriting PLAN with completed steps.

### 7. Validate with user

Present steps, deps, risks. Confirm first implement step.

## Must not

- Write PLAN in English by default; embed implementation code
- Create or overwrite PRD; implement or commit here
- Write PLAN without canonical PRD (except explicit user choice **2** with specs)
- Skip confirm-before-write; claim PLAN saved without `Write`
- `NNN` mismatch vs PRD

## Handoff

```
use skill implement — <full-plan-path> — Step 1
```

One session = one PLAN step.
