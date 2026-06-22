---
name: document-implement
description: Execute the next pending step from docs/documentation-plan/plan.md in the open workspace. Updates plan progress and writes domain docs for RAG. Use when the user says "use skill document-implement", "document repo", or "/document-implement". Requires a plan; handoff to document-plan if missing.
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

# Skill: document-implement

## Trigger

Invoke when the user asks for: `use skill document-implement`, `document repository`, `/document-implement`, or `execute documentation plan`.

Requires `docs/documentation-plan/plan.md` in the **target workspace**. If missing, hand off to `use skill document-plan` (do not invent steps).

## Outcome

One **documentation plan step** completed in the target repo: new/updated markdown under `docs/`, plan progress advanced, next step identified for a future session.

## Lazy-load

| When | Path |
|------|------|
| Plan template, update rules | `skills/document-plan/reference.md` section Plan template & Update protocol |
| SDD vs RAG plan boundary | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 0. Workspace, plan, and stack

1. Confirm **target repository**.
2. Read `docs/documentation-plan/plan.md`. If absent -> stop and suggest `use skill document-plan`.
3. Read **Doc language** from plan header. If missing, ask: **pt-BR** or **English** before writing `docs/`.
4. Re-detect stack briefly (Glob per `document-plan/reference.md` section Stack detection) if plan is stale.

**Not SDD:** only `docs/documentation-plan/plan.md` applies here - not workspace `PLAN/PLAN_*.md` or global `~/.cursor/sdd/<repo-id>/PLAN/`. For feature delivery PRD/PLAN, use `sdd-spec` / `sdd-plan` / `sdd-develop` and `STORAGE.md`.

### 1. Select step

Pick the first step with **Status:** Pending (or **Pendente**) whose dependencies are completed. If user names a step id, use that step after validating deps.

Summarize objective and deliverables; ask to proceed if scope is large.

### 2. Execute step

Follow the step"™s **Tasks** in the plan:

- Glob/Grep/Read source; document facts evidenced in code/config
- Write paths listed in **Deliverables** (e.g. `docs/domains/<slug>.md`)
- Use **doc language** from plan; keep file paths and type names in English
- No secrets, tokens, or internal-only URLs in markdown

### 3. Update plan

Edit `docs/documentation-plan/plan.md` in place:

| Field | Value |
|-------|--------|
| Step status | Completed / Concluido |
| **Completed:** | `YYYY-MM-DD` |
| Deliverables / acceptance | `[x]` when met |
| Progress | `N/M` and bar |
| **Next step** | following pending step |

See `document-plan/reference.md` for bar format.

### 4. Context checkpoint

After the step, follow `context-management.mdc`. At **>= 40%**, save plan + docs and pause - do not start the next plan step in the same session.

### 5. Report

Files written, step completed, progress `N/M`, suggested handoff.

## Must not

- Run without `docs/documentation-plan/plan.md` (unless user gives an explicit alternate plan path)
- Assume MES/Athena or fixed stack versions
- Write product `docs/` before doc language is known
- Complete multiple plan steps in one session when context is high - prefer one step per session
- Require Azure DevOps or external wiki APIs

## Handoff

| Situation | Next |
|-----------|------|
| No plan | `use skill document-plan` |
| Next doc step (new chat) | `use skill document-implement` |
| All steps done | `use skill code-review` (optional) or `use skill commit` |
| Feature code change | `use skill sdd-spec` -> `sdd-plan` -> `sdd-develop` |
