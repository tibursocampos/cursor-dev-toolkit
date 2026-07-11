---
name: sdd-plan
description: Create a baby-step PLAN from an existing PRD. Writes agent PLAN .md in pt-BR by default (repo or ~/.cursor/sdd/<repo-id>/). Use when the user says "use skill sdd-plan", "create plan", "/sdd-plan". Requires a PRD; output feeds sdd-develop.
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

# Skill: sdd-plan

## Trigger

Invoke when the user asks for: `use skill sdd-plan`, `create plan`, `execution plan`, or `/sdd-plan`.

## Outcome

A **PLAN** in **pt-BR** at a **canonical** path under `features/NNN-slug/USnn/PLAN/PLAN_NNN_*.md` (same story as the PRD; global under `~/.cursor/sdd/<repo-id>/features/...`). Legacy root `PLAN/` is **compat read only**. Same `NNN` as PRD. Each step = one `sdd-develop` session. Paths and test names in **English**; no code blocks.

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Pipeline guards, missing PRD dialog | `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md` |
| Storage, manifest, `.gitignore` | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| Caveman Mode (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` - **Lite mode** |
| SDD language, context, .NET | `sdd-artifact-language-pt-br.mdc`, `context-management.mdc`, `dotnet-guidelines/*.md` |

## Process

### -1. Pipeline and mode

Load `STORAGE.md` and `PIPELINE.md`. Use `STORAGE.md` schema v2 and run the dynamic storage resolution algorithm with parameter `$Workflow = classic`. Resolve `storage_mode` and `path` for the active repository. If this is the first run for the repository, execute storage mode selection and persist it in `manifest.json`.
Phase A/B as for `sdd-spec`. No PRD authoring; no production/test code.

Check `~/.cursor/sdd/preferences.json`:
- If file missing -> create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` -> load `~/.cursor/skills/_shared/caveman/CAVEMAN.md` (**Lite mode** rules only) and display:
  > Modo Caveman ativo (respostas compactas - Lite). Digite `caveman off` a qualquer momento para desativar.
- In Lite mode: compress only framing and introductions. Plan drafts, confirmation gates, and clarifying questions are **never** compressed.
- Honor `caveman on` / `caveman off` at any point during the session.

### 0. Workspace

Target repo. Read `AGENTS.md` / `README.md` if present.

### 1. Resolve PRD

Glob canonical PRDs under `features/**/PRD/` (workspace + global feature root). Compat-read legacy `PRD/` / `docs/PRD/` with migration notice.

| Situation | Action |
|-----------|--------|
| User gave canonical PRD path (prefer `features/.../PRD/`) | `Read`; validate status **Pronto para planejamento** / **Ready for planning** |
| No canonical PRD | `PIPELINE.md` section `sdd-plan` without PRD - options 1 or 2; then collect text or file path |
| "Criar PRD" | Choice **1** -> hand off to `sdd-spec` inputs; do not write PLAN until PRD exists (unless user chose **2**) |
| Non-canonical `.md` | Promote per `PIPELINE.md` under `features/...` or ask for file |
| PRD under feature story | Load Prior context siblings (`PIPELINE.md` § Feature / story siblings) |

Summarize PRD; ask to proceed.

### 2-4. Explore, technical questions (<=10), baby steps

Glob/Grep/Read. Steps ~20-45 min each. Doc-update steps: **sdd-develop** asks doc language.

### 5. Context checkpoint

`context-management.mdc`; PLAN draft in chat if >=40%.

### 5.5 PLAN storage

`STORAGE.md`; global PLAN if PRD is global; else manifest or prompt.

### 5.75 Confirm before write

`PIPELINE.md` section Confirm before write - `PLAN_NNN_*`, full path, PRD link, step count. **sim** required before `Write` in Agent.

### 6. Write PLAN (Agent + sim only)

1. Validate canonical PLAN path under same story as PRD (`features/.../PLAN/`); `NNN` **equals** PRD `NNN`. Do **not** write new PLANs at repo-root `PLAN/`.
2. Repository mode: `.gitignore` per `STORAGE.md` (include `/features/`).
3. Template `reference.md`; PRD header = full PRD path; steps **Pendente**; `0/N`.
4. Warn if overwriting PLAN with completed steps.

### 7. Validate with user

Present steps, deps, risks. Confirm first sdd-develop step.

## Must not

- Write PLAN in English by default; embed implementation code
- Create or overwrite PRD; sdd-develop or commit here
- Write PLAN without canonical PRD (except explicit user choice **2** with specs)
- Skip confirm-before-write; claim PLAN saved without `Write`
- `NNN` mismatch vs PRD; new writes outside `features/.../PLAN/`

## Handoff

```
use skill sdd-develop - features/NNN-slug/US01/PLAN/PLAN_NNN_slug.md - Step 1
```

One session = one PLAN step.
