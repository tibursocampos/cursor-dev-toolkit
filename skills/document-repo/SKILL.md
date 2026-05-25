---
name: document-repo
description: Execute the next pending step from docs/documentation-plan/plan.md in the open workspace. Updates plan progress and writes domain docs for RAG. Use when the user says "use skill document-repo", "document repo", or "/document-repo". Requires a plan; handoff to plan-repo-docs if missing.
---

# Skill: document-repo

## Trigger

Invoke when the user asks for: `use skill document-repo`, `document repository`, `/document-repo`, or `execute documentation plan`.

Requires `docs/documentation-plan/plan.md` in the **target workspace**. If missing, hand off to `use skill plan-repo-docs` (do not invent steps).

## Outcome

One **documentation plan step** completed in the target repo: new/updated markdown under `docs/`, plan progress advanced, next step identified for a future session.

## Lazy-load

| When | Path |
|------|------|
| Plan template, update rules | `skills/plan-repo-docs/reference.md` § Plan template & Update protocol |
| SDD vs RAG plan boundary | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 0. Workspace, plan, and stack

1. Confirm **target repository**.
2. Read `docs/documentation-plan/plan.md`. If absent → stop and suggest `use skill plan-repo-docs`.
3. Read **Doc language** from plan header. If missing, ask: **pt-BR** or **English** before writing `docs/`.
4. Re-detect stack briefly (Glob per `plan-repo-docs/reference.md` § Stack detection) if plan is stale.

**Not SDD:** only `docs/documentation-plan/plan.md` applies here — not workspace `PLAN/PLAN_*.md` or global `~/.cursor/sdd/<repo-id>/PLAN/`. For feature delivery PRD/PLAN, use `spec` / `plan` / `implement` and `STORAGE.md`.

### 1. Select step

Pick the first step with **Status:** Pending (or **Pendente**) whose dependencies are completed. If user names a step id, use that step after validating deps.

Summarize objective and deliverables; ask to proceed if scope is large.

### 2. Execute step

Follow the step’s **Tasks** in the plan:

- Glob/Grep/Read source; document facts evidenced in code/config
- Write paths listed in **Deliverables** (e.g. `docs/domains/<slug>.md`)
- Use **doc language** from plan; keep file paths and type names in English
- No secrets, tokens, or internal-only URLs in markdown

### 3. Update plan

Edit `docs/documentation-plan/plan.md` in place:

| Field | Value |
|-------|--------|
| Step status | Completed / Concluído |
| **Completed:** | `YYYY-MM-DD` |
| Deliverables / acceptance | `[x]` when met |
| Progress | `N/M` and bar |
| **Next step** | following pending step |

See `plan-repo-docs/reference.md` for bar format.

### 4. Context checkpoint

After the step, follow `context-management.mdc`. At **≥ 40%**, save plan + docs and pause — do not start the next plan step in the same session.

### 5. Report

Files written, step completed, progress `N/M`, suggested handoff.

## Must not

- Run without `docs/documentation-plan/plan.md` (unless user gives an explicit alternate plan path)
- Assume MES/Athena or fixed stack versions
- Write product `docs/` before doc language is known
- Complete multiple plan steps in one session when context is high — prefer one step per session
- Require Azure DevOps or external wiki APIs

## Handoff

| Situation | Next |
|-----------|------|
| No plan | `use skill plan-repo-docs` |
| Next doc step (new chat) | `use skill document-repo` |
| All steps done | `use skill code-review` (optional) or `use skill commit` |
| Feature code change | `use skill spec` → `plan` → `implement` |
