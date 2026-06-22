---
name: breakdown-tasks
description: Break refined backlog steps into a grouped implementation task checklist saved locally (backend, frontend, tests). No tracker API or fixed corporate workflow tasks. Use when the user says "use skill breakdown-tasks", "break down tasks", or "/breakdown-tasks".
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

# Skill: breakdown-tasks

## Trigger

Invoke when the user asks for: `use skill breakdown-tasks`, `break down tasks`, `/breakdown-tasks`, or after `refine-backlog-item`.

**Input (one of):**

| Source | Example |
|--------|---------|
| Path | `docs/backlog/my-feature.md` |
| Chat | User confirms refined markdown from current session |
| Pasted | User pastes the `### [Steps] Steps` section |

Prerequisite: content includes structured **Steps** (or Bug **Suggested fix**). If missing, hand off to `use skill refine-backlog-item`.

## Outcome

In the **target workspace**: `docs/sdd-developation-tasks/<slug>.md` - grouped checklists for implementation and tests. **No** creation of external work items; **no** mandatory DeskCheck, Datadog, or SDD-tag workflow tasks.

## Lazy-load

| When | Path |
|------|------|
| Grouping rules, output template, optional QA/PR hints | `skills/breakdown-tasks/reference.md` |
| Resolve existing SDD PLAN path (handoff) | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` + `reference.md` section SDD PLAN resolution |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 0. Workspace and source

1. Confirm target repository.
2. Load refined content from path, chat, or paste.
3. Extract steps from `### [Steps] Steps` or Bug `### [Steps] Suggested fix` (see `reference.md` section Parsing).

If no steps found, stop and suggest `use skill refine-backlog-item`.

### 1. Documentation language (blocker before Write)

Ask once:

> Language for `docs/sdd-developation-tasks/` - **pt-BR** or **English**?

Record in the output file header. Paths stay English.

### 2. Group steps

Apply heuristics in `reference.md` section Grouping:

- Prefer `####` sub-headings when present
- Else by repository / service name in step text
- Else by layer (backend vs frontend vs tests)
- Max **5** implementation groups - merge adjacent groups if needed
- **Test steps** (layer Tests / integration / i18n tests) go to dedicated test groups, not mixed into feature implementation groups

### 3. Build checklist file

Write `docs/sdd-developation-tasks/<slug>.md` using `reference.md` section Output template:

- Implementation groups with `- [ ]` per original step (preserve titles and dependencies)
- Separate **Tests** section when test steps exist
- Optional **Before PR** section from neutral checklist in reference (user may omit)

Do **not** inject fixed corporate tasks (AI tags, manual test evidence templates tied to org tools, DeskCheck, Sonar boilerplate as mandatory rows).

### 4. Summarize in chat

Show group names, step ranges, output path, and suggested next skills.

### 5. Handoff

| Situation | Next |
|-----------|------|
| Full SDD for the feature | `use skill sdd-spec` -> `use skill sdd-plan` -> `use skill sdd-develop` |
| PLAN already exists | Resolve SDD PLAN per `STORAGE.md` (repo + `~/.cursor/sdd/<repo-id>/`); then `use skill sdd-develop - <full-plan-path> - Step 1` |
| Code-only small change | `use skill developer` |
| Commit checklist file | `use skill commit` |

## Must not

- Create or update external tracker cards via API
- Add fixed "workflow" tasks (DeskCheck, Datadog log links, SDD/DevAI tags) unless the user explicitly requests a custom section
- Assume `docs/sdd-developation-tasks/` in cursor-dev-toolkit during porting
- Write the file before the language question

## Handoff examples

```
use skill sdd-spec
```

```
use skill sdd-plan
```
