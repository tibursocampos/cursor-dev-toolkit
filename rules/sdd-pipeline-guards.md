---
description: SDD pipeline order, canonical PRD/PLAN paths, confirm-before-write, Plan/Ask vs Agent phases
alwaysApply: true
---

# SDD pipeline guards

Full detail: `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md` (load when running `spec`, `plan`, or `implement`).

## Order

`spec` → `plan` → `implement`. Do not create a PLAN without a canonical PRD (unless the user explicitly chose “PLAN direto” per `PIPELINE.md`). Do not implement without a canonical PLAN on disk.

## Canonical paths only

PRD: `PRD/NNN_*.md`, `docs/PRD/NNN_*.md`, or `~/.cursor/sdd/<repo-id>/PRD/NNN_*.md`.

PLAN: `PLAN/PLAN_NNN_*.md` or global equivalent. PLAN `NNN` matches PRD.

Never save SDD artifacts under `~/.cursor/` (except `sdd/<repo-id>/`), `docs/backlog/`, or ad-hoc `docs/*.md`.

## Missing PRD or PLAN

Ask structured options in **pt-BR** before a dry handoff (`PIPELINE.md` § Missing canonical artifact): create PRD first vs send specs/file in the next message.

## Confirm before write

For **new** PRD or PLAN: show full path + summary, then ask **“Posso gravar em `{path}`? (sim / ajustar / cancelar)”**. `Write` only after **sim**.

## Cursor mode

- **Plan / Ask:** Phase A — questions and draft in chat only. Do **not** claim files were saved without a successful `Write`.
- **Agent:** Phase B — persist after confirmation; run `implement` and `test-coverage`.

When Phase A is done but persistence is pending, tell the user to switch to **Agent** and resend `use skill <name> — gravar`.

## Boundaries

- `spec` / `plan`: no production or test code changes.
- `code-review`: does not write PRD/PLAN; hand off findings with `use skill spec`.
