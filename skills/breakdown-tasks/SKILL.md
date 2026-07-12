---
name: breakdown-tasks
description: Break refined backlog steps into a dependency-aware task checklist (backend, frontend, tests). Prefer features/... story folders. Use when breaking down tasks or invoking /breakdown-tasks.
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
[ ] PIPELINE.md read (SDD skills only)
[ ] User confirmed current action (sim)
-> If any unchecked: STOP
```

---

# Skill: breakdown-tasks

## Trigger

Invoke when the user asks for: `/breakdown-tasks`, `break down tasks`, `/breakdown-tasks`, or after `refine-backlog-item`.

**Input (one of):**

| Source | Example |
|--------|---------|
| Feature story | `features/004-export/US01/STORY.md` |
| Path | `docs/backlog/my-feature.md` |
| Chat | User confirms refined markdown from current session |
| Pasted | User pastes the Steps section |

Prerequisite: content includes structured **Steps** (or Bug **Suggested fix**). If missing, hand off to `/refine-backlog-item`.

## Outcome

In the **target workspace**, a grouped checklist (backend / frontend / tests) with **dependency-aware order** (portable plan-task style - no fixed corporate ADO tasks).

**Persistence (prefer in order):**

1. `features/NNN-slug/USnn/REFINE/tasks.md` - **default** when story folder exists
2. `features/NNN-slug/USnn/TASKS.md` - only if user explicitly asks for flat beside `STORY.md` (do not invent both)
3. Shortcut: `docs/implementation-tasks/<slug>.md` (legacy alias `docs/sdd-developation-tasks/` still accepted)

If both `REFINE/tasks.md` and `TASKS.md` already exist: update **`REFINE/tasks.md`** and note the duplicate in chat (do not fork content into both).

**No** creation of external work items; **no** mandatory DeskCheck, Datadog, or SDD-tag workflow tasks.

## Lazy-load

| When | Path |
|------|------|
| Grouping, topology, output template | `skills/breakdown-tasks/reference.md` |
| Resolve SDD PLAN path (handoff) | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` + `reference.md` § SDD PLAN resolution |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 0. Workspace and source

1. Confirm target repository.
2. Load refined content from feature story, path, chat, or paste.
3. Extract steps from Steps / Suggested fix (`reference.md` § Parsing).

If no steps found, stop and suggest `/refine-backlog-item`.

### 1. Documentation language (blocker before Write)

Ask once:

> Language for the tasks file - **pt-BR** or **English**?

Record in the output file header. Paths stay English.

### 2. Group steps (deps + topology)

Apply `reference.md` § Grouping and § Topological order:

- Honor explicit `Depends on:` edges first (Kahn / levels)
- Then layer / repo heuristics
- Mark steps safe to run in parallel when no edge between them
- Max **5** implementation groups - merge adjacent if needed
- **Test steps** go to dedicated test groups

### 3. Build checklist file

Write preferred path under the story folder (or shortcut) using `reference.md` § Output template - honor Persistence order above (`REFINE/tasks.md` default):

- Implementation groups with `- [ ]` per original step (preserve titles and dependencies)
- Separate **Tests** section when test steps exist
- **Execution order** with critical path + parallel waves
- Optional **Before PR** neutral checklist (user may omit)

Do **not** inject fixed corporate tasks (AI tags, DeskCheck, Sonar boilerplate as mandatory rows).

### 4. Summarize in chat

Show group names, dependency waves, output path, and suggested next skills.

### 5. Handoff

| Situation | Next |
|-----------|------|
| Multi-story / needs O1 | `/orchestrate-analyze` |
| Full SDD for the story | `/sdd-spec` -> `/sdd-plan` -> `/sdd-develop` |
| PLAN already exists | Resolve under `features/**/PLAN/` only (workspace + global feature root); `/sdd-develop - <full-plan-path> - Step 1` |
| Small code-only change | `/developer` / stack `*-developer` |
| Commit checklist file | `/commit` |

## Must not

- Create or update external tracker cards via API (`az`, ADO)
- Add fixed "workflow" tasks (DeskCheck, Datadog, SDD/DevAI tags) unless the user explicitly requests a custom section
- Assume toolkit repo paths during consumer runs
- Write the file before the language question

## Handoff examples

```
/sdd-spec
```

```
/orchestrate-analyze
```

```
/sdd-develop - features/004-export/US01/PLAN/PLAN_004_export.md - Step 1
```
