---
name: spec
description: Create a PRD (Product Requirements Document) for a new feature or change. Collects requirements via structured questions, explores the working repository, and writes PRD/NNN_feature.md or docs/PRD/. Use when the user says "use skill spec", "create spec", "new feature", or "/spec". Output feeds the plan skill.
---

# Skill: spec

## Trigger

Invoke when the user asks for: `use skill spec`, `create spec`, `new feature`, or `/spec`.

## Outcome

A complete **PRD** in English under `PRD/` (preferred) or `docs/PRD/`. The PRD is the mandatory input for the **plan** skill (`use skill plan`).

## PRD boundaries

The PRD answers **what** must be done, not **how** to implement it.

| Include | Exclude |
|---------|---------|
| Business rules, acceptance criteria (Given/When/Then/And) | Implementation code or syntax |
| Validation rules, data flows | Specific variable or method names |
| High-level components, entities, integrations | Class-level design |

## SDD principles

1. Specification before code
2. Measurable, testable acceptance criteria
3. Traceable to implementation and PLAN steps
4. PRD remains the source of truth until superseded

## Lazy-load (only when needed)

| When | Path (after `scripts/sync-cursor.ps1`) |
|------|----------------------------------------|
| .NET architecture context for scope | `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md` |
| C# / test naming context | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` |
| Context pressure before writing PRD | `~/.cursor/rules/context-management.mdc` |

Do **not** preload entire `code-guidelines/` or `dotnet-guidelines/` trees.

## Process

### 0. Load workspace context

Before questioning the user:

1. Confirm you are in the **target repository** (the project being specified), not `cursor-dev-toolkit` unless that is the subject.
2. Read `AGENTS.md` or `README.md` at the repo root if present.
3. Detect stack: `*.sln` / `*.csproj` → .NET; `package.json` + `angular.json` → Angular; else infer from structure.
4. List existing PRDs for numbering: `PRD/*.md`, then `docs/PRD/*.md`.
5. If `docs/` exists, skim files relevant to the feature keywords.

If there is no project `docs/` and the feature is .NET, load dotnet-guidelines only when needed for scope (see table above).

### 1. Collect requirements (manual)

Ask:

```
I will create the PRD. Please provide:

1) Feature description — what should be built or changed?
2) Current behavior — how does it work today?
3) Expected behavior — how should it work after the change?
4) Additional context (optional) — motivation, constraints, links
5) Tracking ID (optional) — GitHub issue, ticket slug, or TBD
```

Wait for answers before continuing.

### 2. Repository confirmation

From the current workspace (`git remote`, repo root path). Present repo name, path, stack, and default branch (ask if unclear: `main`, `develop`, etc.). For multi-repo scope, list each repo and confirm.

### 3. Code exploration (local only)

On the branch the user confirms (fetch/checkout if needed):

- Use **Glob**, **Grep**, **Read** in the workspace — no external code-search APIs.
- Note patterns (entities, handlers, APIs) the feature will touch.

Summarize files reviewed and patterns found.

### 4. Clarification (max 5 questions)

Ask about business rules, edge cases, integrations, compatibility, and validations. Do not assume missing details.

### 5. Technical analysis

Document briefly for the PRD (Impact, Complexity Low/Medium/High, Risks, Dependencies; Migrations and events if applicable).

### 6. Context checkpoint

Follow `~/.cursor/rules/context-management.mdc`. If usage is at or above 40%, persist a draft PRD and warn before continuing.

### 7. Write PRD

1. Output folder: `PRD/` if present or conventional; otherwise `docs/PRD/`.
2. Filename: `NNN_short_feature_slug.md` — `NNN` = next 3-digit sequence; slug = kebab-case English.
3. Body: full template in `reference.md` (this repo: `skills/spec/reference.md`; installed: `~/.cursor/skills/spec/reference.md`).
4. Set status **Ready for planning**.
5. Handoff: `use skill plan` with the PRD path.

Report: full path, sequence, complexity, resolved open questions.

## Must not

- External work-item APIs, MCP trackers, or `repo-mappings.json`
- Clone repositories only for spec (use the open workspace)
- Paste full guideline bodies into the PRD
- Deprecated SDD skill aliases in user-facing handoff text (use `plan` and `implement` only)

## Handoff

```
use skill plan — PRD/<path>.md
```
