---
name: plan-repo-docs
description: Create a baby-step documentation plan for the open workspace (overview + domain deep dives for RAG). Detects stack via Glob. Asks doc language before writing product docs. Use when the user says "use skill plan-repo-docs", "plan repo docs", or "/plan-repo-docs". Optional path to a reviewed overview file.
---

# Skill: plan-repo-docs

## Trigger

Invoke when the user asks for: `use skill plan-repo-docs`, `plan repo documentation`, `/plan-repo-docs`, or `doc plan`.

Optional argument: path to an existing **reviewed** `docs/overview.md` (or equivalent) to seed the plan.

## Outcome

In the **target workspace** (not `cursor-dev-toolkit` unless that is the repo to document):

- `docs/documentation-plan/plan.md` — baby-step documentation plan with progress tracking
- `docs/overview.md` — high-level repo summary (created or refreshed unless user supplied overview)

Product documentation prose follows the **language the user chooses** (pt-BR or English). File paths stay in English.

## Lazy-load

| When | Path |
|------|------|
| Plan template, domain checklist | `skills/plan-repo-docs/reference.md` or `~/.cursor/skills/plan-repo-docs/reference.md` after sync |
| SDD vs RAG plan boundary | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` (read § Read-only discovery — do not conflate paths) |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 0. Workspace and stack

1. Confirm **target repository** (consumer app/service — not the toolkit unless explicit).
2. Detect stack with Glob (see `reference.md` § Stack detection). Summarize: languages, frameworks, layout — **do not** assume a fixed corporate stack.
3. Read `AGENTS.md` / `README.md` if present.

**Not SDD:** this skill writes `docs/documentation-plan/plan.md` only — not `PLAN/PLAN_*.md` or `~/.cursor/sdd/<repo-id>/PLAN/`. Feature PRD/PLAN use `spec` / `plan` / `implement` per `STORAGE.md`.

### 1. Documentation language (blocker)

Before creating or updating any file under `docs/` in the target repo, ask once:

> Documentation language for product `docs/` — **pt-BR** or **English**?

Record the choice in the session and in `docs/documentation-plan/plan.md` header (see template).

### 2. Existing artifacts

| Path | Action |
|------|--------|
| `docs/documentation-plan/plan.md` | If exists: read completed steps; resume or ask to overwrite |
| `docs/overview.md` | Use user-provided path, existing file, or generate from exploration |
| Neither | Create both per `reference.md` |

### 3. Explore and draft overview

Glob/Grep/Read: solution layout, main entry points, bounded contexts, external integrations, test layout. Write or update `docs/overview.md` in the chosen language — concise, RAG-friendly, no invented business domain names.

### 4. Write documentation plan

Create or update `docs/documentation-plan/plan.md` using `reference.md` § Plan template:

- Baby steps per business/technical domain
- Steps for integrations, architecture patterns, and folder conventions
- Progress `0/N`, status per step (**Pending** / **Completed**)
- Each step sized for one `document-repo` session where possible

### 5. Context checkpoint

After finishing overview + plan (or after each major planning chunk if the repo is large), follow `context-management.mdc`: at **≥ 40%** context, save `plan.md` and pause; ask whether to continue in a new chat.

### 6. Summarize handoff

Report: paths written, language, step count, first pending step id.

```
use skill document-repo
```

## Must not

- Embed MES, Athena, or organization-specific product context
- Require Azure DevOps, corporate wikis, or fixed .NET/Angular versions without detection
- Create `docs/documentation-plan/` inside **cursor-dev-toolkit** during porting (only in consumer repos at runtime)
- Write `docs/` before the language question is answered
- Default product doc language without asking

## Handoff

| Situation | Next |
|-----------|------|
| Execute next doc step | `use skill document-repo` |
| Code change needed | `use skill dotnet-developer` or SDD `implement` |
| Commit docs | `use skill commit` |
