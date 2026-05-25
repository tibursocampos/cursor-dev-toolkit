---
name: refine-backlog-item
description: Refine an informal backlog item (Bug, User Story, Technical Story) into structured markdown with BDD acceptance criteria and a quality scorecard. Optional save to docs/backlog/ in the target repo. No tracker API. Use when the user says "use skill refine-backlog-item", "refine backlog", or "/refine-backlog-item".
---

# Skill: refine-backlog-item

## Trigger

Invoke when the user asks for: `use skill refine-backlog-item`, `refine backlog item`, `/refine-backlog-item`, or quick intake before SDD.

Optional: path to existing notes, or pasted description.

## Outcome

Structured **markdown** in chat (BDD acceptance criteria + implementation steps) and a **quality scorecard**. Optionally persisted as `docs/backlog/<slug>.md` in the **target workspace** — not in `cursor-dev-toolkit` unless that repo is the subject.

Does **not** create or update cards in external work-item trackers.

## Lazy-load

| When | Path |
|------|------|
| Type templates | `skills/_shared/backlog-item-types/{bug,user-story,technical-story}.md` or `~/.cursor/skills/_shared/backlog-item-types/` after sync |
| Scorecard rubric, spec boundary, guardrails | `skills/refine-backlog-item/reference.md` |
| Existing PRDs before SDD handoff (read-only) | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 0. Workspace

Confirm **target repository** (the product being described). Summarize detected stack via Glob if useful for steps and repositories sections.

Do **not** assume there is no PRD because `PRD/` is missing in the workspace — existing PRDs may live under `~/.cursor/sdd/<repo-id>/PRD/` per `STORAGE.md`.

### 1. Select item type

```
📋 Refine backlog item

Which type?

1️⃣  Bug
2️⃣  User Story
3️⃣  Technical Story
```

Load the matching file from `_shared/backlog-item-types/`.

### 2. Collect description

Ask for a free-form description (problem, goal, context, constraints). Wait for enough detail; if thin, use collection questions from the type file — do not ship placeholder `[...]` sections.

### 3. Generate documentation

Follow the type file **Output template** and **Writing guidelines**. Combine user input with structure from the template — calibrate depth, not copy corporate examples from other repos.

**Steps (User Story / Technical Story / Bug fix):** one responsibility per step; infinitive verbs; layer order when applicable; explicit dependencies; note parallel steps when independent.

**BDD:** **Given / When / Then / And**; verifiable outcomes; avoid vague "works correctly".

### 4. Quality scorecard

Immediately after the markdown, score per `reference.md` § Scorecard. Show total / 100, strengths, and specific improvements.

### 5. Validation (chat-only)

Before presenting as final, check `reference.md` § Guardrails (no vague phrases, no unit-test AC, complete sections).

### 6. Optional persistence

Ask whether to save under `docs/backlog/<slug>.md` in the target repo.

If yes, **first** ask once:

> Language for product `docs/backlog/` — **pt-BR** or **English**?

Write prose in that language; paths and identifiers stay in English. Slug from title (kebab-case).

### 7. Handoff

| Situation | Next |
|-----------|------|
| Break into implementation checklist | `use skill breakdown-tasks` (same content or saved path) |
| Medium/high complexity feature | `use skill spec` → `use skill plan` → `use skill implement` |
| Small isolated .NET change | `use skill dotnet-developer` |
| Commit saved file | `use skill commit` |

## Must not

- Call tracker REST APIs, MCP work-item integrations, or PAT scripts
- Add organization-specific custom fields, mandatory AI tags, or PATCH guardrails for remote boards
- Write `docs/backlog/` before the language question when saving
- Duplicate PRD/PLAN templates — hand off to `spec` / `plan` for SDD artifacts

## Handoff examples

```
use skill breakdown-tasks — docs/backlog/export-archived-records.md
```

```
use skill spec
```
