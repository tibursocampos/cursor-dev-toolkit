# PRD 001 — Personal Cursor agent toolkit

| Field | Value |
|-------|--------|
| **Feature** | Personal Cursor agent toolkit |
| **Status** | MVP complete |
| **Repository** | `cursor-dev-toolkit` |
| **PRD path** | `PRD/001_cursor_dev_toolkit.md` |
| **Plan path** | `PLAN/PLAN_001_cursor_dev_toolkit.md` |

## Problem

A personal Cursor setup needs a neutral, publishable agent toolkit: Git-only workflows, English guidelines, SDD (spec → plan → implement), and a modern .NET test stack (xUnit, Moq, FluentAssertions) without external work-item or corporate pipeline integrations.

## Goals

1. Publishable personal toolkit repo with English guidelines.
2. Installable to `~/.cursor/` via sync script.
3. Operational SDD cycle: spec → plan → implement.
4. Token-efficient structure (split skills, lazy-load router).

## Out of scope

- Third-party product branding in names or docs
- Work-item tracker integration (Azure DevOps, MCP linking)
- Corporate static-analysis fix workflows
- Bundled slash-command packs
- Fixed corporate pipeline layouts (v1)
- Automatic LLM model selection via hooks

## Conventions (fixed)

| Area | Rule |
|------|------|
| Branding | Neutral; no third-party product names in toolkit content |
| Skill names | English, kebab-case |
| Guidelines | English |
| Code & tests | English identifiers |
| Test names | `Should_<Result>_When_<Condition>` |
| Test stack | xUnit + Moq + FluentAssertions (new code) |
| Guidelines folder | `dotnet-guidelines/` |
| User language | Agent replies in pt-BR (`rules/user-language-pt-br.md`) |

## Functional requirements

- **FR1**: Router `AGENTS.md` with SDD flow and lazy-load table.
- **FR2**: `dotnet-guidelines` (Clean Architecture, EN, xUnit/Moq).
- **FR3**: Skills `spec`, `plan`, `implement`, `code-review`, `commit`, `dotnet-developer`.
- **FR4**: Git-only `developer-common` steps (0, 0.5, 3, 3.5, 4, 7).
- **FR5**: Rules `conventional-commits`, `branch-validation`, `context-management` as `.mdc` sources.
- **FR6**: Optional `sync-cursor.ps1` and context hooks (no model selection).

## Non-functional requirements

- **NFR1**: Each skill `SKILL.md` body ≤ 150 lines (remainder in `reference.md`).
- **NFR2**: No corporate URLs or secrets in repo.
- **NFR3**: Build using token-optimized sessions per PLAN.

## Success criteria

- [x] MVP deployable to `~/.cursor/` from sync script
- [x] Toolkit content uses neutral language only (no legacy project references)
- [ ] SDD cycle verified once on a dummy feature
- [x] Skills use current names only (`spec`, `plan`, `implement`, `commit`, etc.)

## Skills (MVP)

| Skill | Purpose |
|-------|---------|
| `spec` | PRD from feature request |
| `plan` | Baby-step PLAN from PRD |
| `implement` | One PLAN step per session |
| `code-review` | Review diff or branch |
| `commit` | Conventional commit and push |
| `dotnet-developer` | Small .NET work without full SDD |

## References

- Build plan: `PLAN/PLAN_001_cursor_dev_toolkit.md`
- Token strategy: `docs/TOKEN_BUDGET.md`
- Maintainer guide: `docs/MAINTAINER_GUIDE.md`
