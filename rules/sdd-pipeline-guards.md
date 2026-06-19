---
description: SDD pipeline order, canonical PRD/PLAN paths, confirm-before-write, Plan/Ask vs Agent phases
alwaysApply: true
---

# SDD pipeline guards

Full detail: `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md` (load when running `spec`, `plan`, or `implement`).

## Order

- **Classic SDD**: `spec` → `plan` → `implement`. Do not create a PLAN without a canonical PRD (unless "PLAN direto"). Do not implement without a canonical PLAN.
- **Spec Kit**: `speckit-spec` → `speckit-plan` → `speckit-develop`. Do not plan without a spec, and do not develop without tasks.

## Canonical paths only

### Classic SDD
- PRD: `PRD/NNN_*.md`, `docs/PRD/NNN_*.md`, or `~/.cursor/sdd/<repo-id>/PRD/NNN_*.md`.
- PLAN: `PLAN/PLAN_NNN_*.md` or global equivalent. PLAN `NNN` matches PRD.

### Spec Kit
- Spec: `.specify/specs/NNN-<slug>/spec.md` or global equivalent `~/.cursor/sdd/<repo-id>/.specify/specs/NNN-<slug>/spec.md`.
- Plan/Tasks: `.specify/specs/NNN-<slug>/plan.md` and `tasks.md` in the same directory.

Never save SDD artifacts under `~/.cursor/` (except `sdd/<repo-id>/`), `docs/backlog/`, or ad-hoc `docs/*.md`.

## Missing PRD/Spec or PLAN/Tasks

Ask structured options in **pt-BR** before a dry handoff (`PIPELINE.md` § Missing canonical artifact): create artifact first vs send details in the next message.

## Confirm before write

For **new** PRD, PLAN, Spec or Plan/Tasks: show full path + summary, then ask **“Posso gravar em `{path}`? (sim / ajustar / cancelar)”**. `Write` only after **sim**.

## Cursor mode

- **Plan / Ask:** Phase A — questions and draft in chat only. Do **not** claim files were saved without a successful `Write`.
- **Agent:** Phase B — persist after confirmation; run `implement`, `speckit-develop` and `test-coverage`.

When Phase A is done but persistence is pending, tell the user to switch to **Agent** and resend `use skill <name> — gravar`.

## Boundaries

- `spec` / `plan` / `speckit-spec` / `speckit-plan`: no production or test code changes.
- `code-review`: does not write PRD/PLAN/Spec; hand off findings with `use skill spec` or `use skill speckit-spec`.
