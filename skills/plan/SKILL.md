---
name: plan
description: Create a baby-step PLAN from an existing PRD. Writes agent PLAN .md in pt-BR by default (repo or ~/.cursor/sdd/<repo-id>/). Use when the user says "use skill plan", "create plan", "/plan". Requires a PRD; output feeds implement.
---

# Skill: plan

## Trigger

Invoke when the user asks for: `use skill plan`, `create plan`, `execution plan`, or `/plan`.

## Outcome

A complete **PLAN** (agent `.md` artifact) in **Brazilian Portuguese (pt-BR)** at the resolved path (`PLAN/PLAN_NNN_*.md` or global). Same `NNN` as the PRD. English only if the user overrides in this invocation. Each step fits **one** `implement` session.

The PLAN is **how** (ordered baby steps); the PRD is **what**. File paths and test names in **English**; no implementation code blocks.

## Lazy-load (only when needed)

| When | Path (after sync) |
|------|-------------------|
| SDD artifact language | `~/.cursor/rules/sdd-artifact-language-pt-br.mdc` |
| Storage, manifest, `.gitignore` | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| .NET layering | `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md` |
| Tests naming | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 0. Workspace context

1. Confirm target repository (per PRD).
2. Read `AGENTS.md` or `README.md` if present.
3. If no PRD path, ask and stop.

### 1. Load and validate PRD

Read PRD (repo or global). Status **Pronto para planejamento** / **Ready for planning**. Summarize and ask to proceed.

### 2. Branch and exploration

Explore open workspace with Glob/Grep/Read. Summarize files and patterns.

### 3. Technical questions (max 10)

Clarify gaps only.

### 4. Baby steps

Size each step for one `implement` session (~20–45 min). Split if 4+ new files, migration+mapping together, etc.

Optional final step: update project `docs/` — if included, note that **implement** must **ask** doc language (pt-BR vs English) before writing.

### 5. Context checkpoint

Follow `context-management.mdc`. Save PLAN draft if ≥ 40% before validation dialogue.

### 5.5 Choose PLAN storage

Load `STORAGE.md`. If PRD path is under `~/.cursor/sdd/`, use global PLAN. Else read manifest or ask storage. Update manifest (`artifact_language`, folders).

### 6. Write PLAN

1. Apply `sdd-artifact-language-pt-br.mdc` (pt-BR unless override in invocation).
2. Folder from manifest; **repository mode:** `.gitignore` per `STORAGE.md` (`/PRD/`, `/PLAN/`, `/docs/PRD/`, `/docs/PLAN/` — all four before first write).
3. `PLAN_NNN_short_feature_slug.md`; **PRD** header = full PRD path.
4. Body: `reference.md` template (pt-BR). Status **Pendente** on steps; progress `0/N`.
5. Overwrite warning if PLAN exists with completed steps.

Report: full path, storage, artifact language, step count, estimates, risks.

### 7. Validate with user

Present steps, dependencies, risks. Confirm first step.

## Must not

- Write PLAN body in English by default
- Embed implementation code in the PLAN
- Write product `docs/` without language question in the step/handoff
- Implement code, commit, or run full test suites here

## Handoff

```
use skill implement — <full-plan-path> — Step 1
```

One chat session = one PLAN step.
