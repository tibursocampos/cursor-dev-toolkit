---
name: plan
description: Create a baby-step execution PLAN from an existing PRD. Reads the PRD, explores the open workspace, breaks work into one-session steps, and writes PLAN/PLAN_XXX.md. Use when the user says "use skill plan", "create plan", "execution plan", or "/plan". Requires a PRD; output feeds the implement skill.
---

# Skill: plan

## Trigger

Invoke when the user asks for: `use skill plan`, `create plan`, `execution plan`, or `/plan`.

## Outcome

A complete **PLAN** in English at `PLAN/PLAN_XXX_feature_slug.md` (same sequence as the PRD). Each step is sized for **one** `implement` session. Hand off with `use skill implement`.

The PLAN is **how** (ordered baby steps); the PRD is **what**. Include steps, dependencies, files, acceptance, progress for `implement`. Exclude code, clones, trackers, commits, or CI runs. PRD path is mandatory.

## Lazy-load (only when needed)

| When | Path (after `scripts/sync-cursor.ps1`) |
|------|----------------------------------------|
| .NET structure / layering for steps | `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md` |
| Test naming and stack (xUnit, Moq, `Should_<Result>_When_<Condition>`) | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` |
| Context pressure while writing PLAN | `~/.cursor/rules/context-management.mdc` |

Do **not** preload entire `code-guidelines/` or `dotnet-guidelines/` trees.

## Process

### 0. Workspace context

1. Confirm you are in the **target repository** (the project in the PRD), not `cursor-dev-toolkit` unless that is the subject.
2. Read `AGENTS.md` or `README.md` at the repo root if present.
3. If the user did not pass a PRD path, ask for it and stop until provided.

### 1. Load and validate PRD

1. Read the PRD file (e.g. `PRD/NNN_feature.md` or `docs/PRD/...`).
2. **Status** must be **Ready for planning** (or equivalent approved state). If **Draft**, warn and wait for explicit confirmation.
3. Extract: objectives, acceptance criteria, functional/non-functional requirements, impacts, complexity, repository name, stack.
4. Present a short summary and ask to proceed.

### 2. Branch and exploration

Ask baseline branch (`main`, `develop`, etc.). Explore with **Glob**, **Grep**, **Read** in the **open workspace** only — no clone-from-spec paths or external code APIs. Map modules, types, APIs, migrations, tests; load dotnet-guidelines only for .NET (see table). Summarize files and patterns.

### 3. Technical questions (max 10)

Clarify only gaps: naming, migrations, contracts, validation, tests. Do not assume missing details.

### 4. Baby steps

Break work into steps that each fit **one** `implement` session (~20–45 minutes of focused work).

| Signal | Action |
|--------|--------|
| 4+ new files in one step | Split into two steps |
| Handler + consumer + tests together | Separate by responsibility |
| Migration + EF mapping in one step | Split migration and mapping |
| Step reads many large files | Split by file or layer |

Prefer more small steps over fewer large ones. Each step must list: objective, files, tasks, tests, acceptance checkboxes, dependencies, estimate.

Optional final step: update project `docs/` when behavior or contracts change (skip for pure refactors with no contract change).

### 5. Context checkpoint

Follow `~/.cursor/rules/context-management.mdc`. If usage is at or above 40% after drafting steps, save PLAN to disk and warn before validation dialogue.

### 6. Write PLAN

1. Folder: `PLAN/` at repo root (create if missing).
2. Filename: `PLAN_NNN_short_feature_slug.md` — `NNN` matches PRD sequence; slug = kebab-case English.
3. If a PLAN for the same PRD exists, warn about overwrite; wait for confirmation before replacing completed steps.
4. Body: full template in `reference.md` (repo: `skills/plan/reference.md`; installed: `~/.cursor/skills/plan/reference.md`).
5. Set overall status **Not started**; progress `0/N`.
6. Link PRD path in the PLAN header.

Report: full path, step count, total estimate, risks, dense steps flagged for context.

### 7. Validate with user

Present step list, dependencies, and risks. Adjust if the user requests changes. Confirm understanding of the first step.

## Must not

- Clone repositories “because spec did” — use the open workspace only
- ADO, MCP work items, `repo-mappings.json`, or corporate pipeline docs
- Implement code, create branches, commit, or run full test suites (those belong to **implement**)
- Use deprecated skill aliases in handoff text (use `plan` and `implement` only)
- Paste full guideline bodies into the PLAN

## Handoff

```
use skill implement — PLAN/PLAN_NNN_feature_slug.md — Step 1
```

One chat session = one PLAN step; start a new session for the next step.
