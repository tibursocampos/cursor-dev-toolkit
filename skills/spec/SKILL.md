---
name: spec
description: Create a PRD for a new feature or change. Writes agent PRD .md in pt-BR by default (repo or ~/.cursor/sdd/<repo-id>/). Use when the user says "use skill spec", "create spec", "new feature", or "/spec". Output feeds the plan skill.
---

# Skill: spec

## Trigger

Invoke when the user asks for: `use skill spec`, `create spec`, `new feature`, or `/spec`.

## Outcome

A complete **PRD** (agent `.md` artifact) in **Brazilian Portuguese (pt-BR)** at the resolved folder: repository (`PRD/` or `docs/PRD/`) or global (`~/.cursor/sdd/<repo-id>/PRD/`). English only if the user overrides in this invocation. Mandatory input for **plan** (`use skill plan`).

## PRD boundaries

The PRD answers **what** must be done, not **how** to implement it.

| Include | Exclude |
|---------|---------|
| Business rules, acceptance criteria (Dado/Quando/Então/E) | Implementation code or syntax |
| Validation rules, data flows | Full class-level design |
| High-level components, entities, integrations | — |

**Identifiers** in the PRD (types, methods, APIs, paths) stay in **English**.

## SDD principles

1. Specification before code
2. Measurable, testable acceptance criteria
3. Traceable to implementation and PLAN steps
4. PRD remains the source of truth until superseded

## Lazy-load (only when needed)

| When | Path (after `scripts/sync-cursor.ps1`) |
|------|----------------------------------------|
| SDD artifact language (default pt-BR) | `~/.cursor/rules/sdd-artifact-language-pt-br.mdc` |
| PRD/PLAN storage, manifest, `.gitignore` | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
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
4. Resolve `<repo-id>` per `STORAGE.md`; list existing PRDs in workspace and global for `NNN`.
5. If `docs/` exists, skim files relevant to the feature keywords.

### 1. Collect requirements (manual)

Ask (pt-BR in chat):

```
Vou criar o PRD. Informe:

1) Descrição da feature — o que deve ser construído ou alterado?
2) Comportamento atual — como funciona hoje?
3) Comportamento esperado — como deve funcionar após a mudança?
4) Contexto adicional (opcional) — motivação, restrições, links
5) ID de rastreamento (opcional) — issue GitHub, slug, ou TBD
```

Wait for answers before continuing.

### 2. Repository confirmation

From the current workspace (`git remote`, repo root path). Present repo name, path, stack, and default branch (ask if unclear: `main`, `develop`, etc.).

### 3. Code exploration (local only)

On the branch the user confirms: **Glob**, **Grep**, **Read** in the workspace only. Summarize files and patterns.

### 4. Clarification (max 5 questions)

Ask about business rules, edge cases, integrations, compatibility, and validations.

### 5. Technical analysis

Document briefly for the PRD (impacto, complexidade, riscos, dependências; migrações e eventos se aplicável).

### 6. Context checkpoint

Follow `~/.cursor/rules/context-management.mdc`. If usage is at or above 40%, persist a draft PRD and warn before continuing.

### 6.5 Choose storage location

Load `STORAGE.md`. Read manifest if valid; else ask storage (pt-BR prompt in `STORAGE.md`). Record choice; write or update manifest (`artifact_language`: `pt-BR` unless English override in invocation).

### 7. Write PRD

1. Apply `sdd-artifact-language-pt-br.mdc` (pt-BR body unless override in invocation).
2. Output folder from manifest / user choice; **repository mode:** `.gitignore` per `STORAGE.md`.
3. Filename: `NNN_short_feature_slug.md` — ASCII slug (Portuguese words allowed).
4. Body: template in `reference.md` (pt-BR default). Status **Pronto para planejamento** (or **Ready for planning** if EN override).
5. If scope includes **product** docs in `docs/` or README: **ask** pt-BR vs English before writing that documentation.
6. Handoff: `use skill plan — <full-prd-path>`.

Report: full path, storage mode, artifact language, `.gitignore` changes (if any), sequence, complexity.

## Must not

- Write PRD body in English by default
- Put implementation code in the PRD
- Create product `docs/` without asking language first
- External work-item APIs, MCP trackers, or `repo-mappings.json`
- Paste full guideline bodies into the PRD

## Handoff

```
use skill plan — <full-prd-path>
```
