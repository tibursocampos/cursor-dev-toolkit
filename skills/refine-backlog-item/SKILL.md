---
name: refine-backlog-item
description: Refine an informal backlog item (Bug, User Story, Technical Story) into structured markdown with BDD acceptance criteria and a quality scorecard. Prefer features/.../STORY.md; docs/backlog/ as shortcut. No tracker API. Use when the user says "use skill refine-backlog-item", "refine backlog", or "/refine-backlog-item".
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

# Skill: refine-backlog-item

## Trigger

Invoke when the user asks for: `use skill refine-backlog-item`, `refine backlog item`, `/refine-backlog-item`, or quick intake before SDD / Forma C.

Optional: path to existing notes, or pasted description.

## Outcome

Structured **markdown** in chat (BDD acceptance criteria + implementation steps) and a **quality scorecard** aligned to portable document-task patterns (no ADO).

**Persistence (prefer in order):**

1. `features/NNN-slug/USnn/STORY.md` (or `TSnn`) under resolved classic feature root - optional `REFINE/` notes beside it
2. Shortcut: `docs/backlog/<slug>.md` in the **target workspace**

Does **not** create or update cards in external work-item trackers.

## Lazy-load

| When | Path |
|------|------|
| Type templates | `skills/_shared/backlog-item-types/{bug,user-story,technical-story}.md` or `~/.cursor/skills/_shared/backlog-item-types/` after sync |
| Scorecard rubric, boundaries vs O1 / sdd-spec | `skills/refine-backlog-item/reference.md` |
| Feature storage | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md`, `PIPELINE.md` |
| Story template | `skills/_shared/templates/features/story/STORY.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 0. Workspace

Confirm **target repository**. Summarize detected stack via Glob if useful.

Do **not** assume there is no PRD because root `PRD/` is missing - check `features/**/PRD/` and global per `STORAGE.md`.

### 1. Select item type

```
[Refine] Refine backlog item

Which type?

1) Bug
2) User Story
3) Technical Story
```

Load the matching file from `_shared/backlog-item-types/`. Map: User Story -> `USnn`, Technical Story -> `TSnn`, Bug -> prefer `USnn` or note under existing story.

### 2. Collect description

Ask for a free-form description (problem, goal, context, constraints). Wait for enough detail; if thin, use collection questions from the type file - do not ship placeholder `[...]` sections.

### 3. Generate documentation

Follow the type file **Output template** and **Writing guidelines**. Combine user input with structure from the template - calibrate depth, not copy corporate examples.

**Steps:** one responsibility per step; infinitive verbs; layer order when applicable; explicit dependencies; note parallel steps when independent (feeds `breakdown-tasks` topological grouping).

**BDD:** **Given / When / Then / And**; verifiable outcomes; avoid vague "works correctly".

### 4. Quality scorecard

Immediately after the markdown, score per `reference.md` section Scorecard. Show total / 100, strengths, and specific improvements.

### 5. Validation (chat-only)

Before presenting as final, check `reference.md` section Guardrails.

### 6. Optional persistence

Ask where to save (pt-BR):

```text
Onde gravar o item refinado?

1) features/NNN-slug/USnn/STORY.md (recomendado - Forma B alinhada ao storage)
2) docs/backlog/<slug>.md (atalho)
3) Só chat (não gravar)
```

If saving under `features/`: resolve feature root (`STORAGE.md`); create `FEATURE.md` stub only if missing and user confirms path; ask artifact language default **pt-BR**.

If saving under `docs/backlog/`: **first** ask once:

> Language for product `docs/backlog/` - **pt-BR** or **English**?

Write prose in that language; paths and identifiers stay in English. Slug from title (kebab-case).

### 7. Handoff

| Situation | Next |
|-----------|------|
| Break into implementation checklist | `use skill breakdown-tasks` (same content or saved path) |
| Multi-story / complex / needs specialists | `use skill orchestrate-analyze` (Forma C O1) |
| Medium/high complexity single feature (Forma A) | `use skill sdd-spec` -> `use skill sdd-plan` -> `use skill sdd-develop` |
| Small isolated change | `use skill developer` / stack `*-developer` |
| Commit saved file | `use skill commit` |

## Must not

- Call tracker REST APIs, MCP work-item integrations, or PAT scripts (`az`, ADO)
- Add organization-specific custom fields, mandatory AI tags, or PATCH guardrails for remote boards
- Write `docs/backlog/` before the language question when choosing shortcut
- Duplicate full PRD/PLAN templates - hand off to `sdd-spec` / `sdd-plan` or O1
- Invent architecture that belongs to O1 specialists

## Handoff examples

```
use skill breakdown-tasks - features/004-export/US01/STORY.md
```

```
use skill orchestrate-analyze
```

```
use skill sdd-spec
```
