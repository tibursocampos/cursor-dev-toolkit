---
description: SDD pipeline order, canonical PRD/PLAN paths, confirm-before-write, Plan/Ask vs Agent phases
alwaysApply: true
---

# SDD pipeline guards

Full detail: `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md` (load when running `sdd-spec`, `sdd-plan`, or `sdd-develop`).

## Order

- **Classic SDD (Forma A)**: `sdd-spec` -> `sdd-plan` -> `sdd-develop`. Do not create a PLAN without a canonical PRD (unless "PLAN direto"). Do not implement without a canonical PLAN.
- **Forma C**: `orchestrate-analyze` -> `orchestrate-deliver` -> (`orchestrate-develop` \| `sdd-develop`) after human gates.
- **Spec Kit**: `speckit-spec` -> `speckit-plan` -> `speckit-develop`. Do not plan without a spec, and do not develop without tasks.

## Canonical paths only

### Classic SDD (new writes)

- PRD: `features/NNN-slug/USnn/PRD/NNN_*.md` (default story `US01`) or global under `~/.cursor/sdd/<repo-id>/features/...`.
- PLAN: `features/NNN-slug/USnn/PLAN/PLAN_NNN_*.md` or global equivalent. PLAN `NNN` matches PRD.
- Legacy root `PRD/` / `PLAN/` / `docs/PRD/`: **compat read only** (migration notice).

### Spec Kit

- Spec: `.specify/specs/NNN-<slug>/spec.md` or global equivalent.
- Plan/Tasks: `.specify/specs/NNN-<slug>/plan.md` and `tasks.md` in the same directory.

Never save **new** SDD artifacts under `docs/backlog/` or ad-hoc `docs/*.md` for canonical SDD. Prefer feature tree for Forma B stories (`STORY.md`); `docs/backlog/` is a shortcut only.

## Missing PRD/Spec or PLAN/Tasks

Ask structured options in **pt-BR** before a dry handoff (`PIPELINE.md` § Missing canonical artifact): create artifact first vs send details in the next message.

## Confirm before write

For **new** PRD, PLAN, Spec or Plan/Tasks: show full path + summary, then ask **"Posso gravar em `{path}`? (sim / ajustar / cancelar)"**. `Write` only after **sim**.

## Cursor mode

- **Plan / Ask:** Phase A - questions and draft in chat only. Do **not** claim files were saved without a successful `Write`.
- **Agent:** Phase B - persist after confirmation; run `sdd-develop`, `speckit-develop` and `test-coverage`.

When Phase A is done but persistence is pending, tell the user to switch to **Agent** and resend `use skill <name> - gravar`.

## Boundaries

- `sdd-spec` / `sdd-plan` / `speckit-spec` / `speckit-plan`: no production or test code changes.
- `sdd-develop`: **one PLAN step per develop session** (unchanged contract). Develop gates (`step_confirmed`, `tests_run`) live in PLAN-scoped files under `~/.cursor/sdd/sessions/{repo-hash}/` — see `SESSION.md` (supports parallel O3 without sharing one flat session JSON).
- `code-review`: does not write PRD/PLAN/Spec; hand off findings with `use skill sdd-spec` or `use skill speckit-spec`.
