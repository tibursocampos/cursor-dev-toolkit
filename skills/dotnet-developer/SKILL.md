---
name: dotnet-developer
description: Implement or fix small-to-medium .NET features without full SDD. Uses Clean Architecture, xUnit/Moq/FluentAssertions, and Git-only developer-common steps. Use when the user says "use skill dotnet-developer", "dotnet fix", or for isolated C# work. For large cross-cutting features, prefer spec → plan → implement.
---

# Skill: dotnet-developer

## Trigger

Invoke when the user asks for: `use skill dotnet-developer`, `dotnet fix`, `implement .NET feature`, or for **small** backend work that does not need a full PRD/PLAN cycle.

## Outcome

Working **.NET** code and tests in the open workspace: build and tests green, on a valid feature branch, with optional commit handoff. Does not replace SDD for multi-step or cross-repo features.

## When to prefer SDD instead

Recommend `use skill spec` → `plan` → `implement` if **two or more** apply:

| Signal | Indicator |
|--------|-----------|
| Layers | 3+ layers (Domain, Application, Infrastructure, API) |
| Database | New or altered schema / migrations |
| Repos | Backend and another repo or service |
| Integrations | New messaging, external APIs, or consumers |
| Size | 10+ files or estimated 4+ hours |
| PLAN exists | User already has an approved PLAN — use `implement` |

## Lazy-load (only when needed)

| When | Path (after `scripts/sync-cursor.ps1`) |
|------|----------------------------------------|
| Repo context | `~/.cursor/skills/_shared/developer-common/step-0-context.md` |
| Before coding | `~/.cursor/skills/_shared/developer-common/step-0.5-review-guidelines.md` |
| Branching | `~/.cursor/rules/branch-validation.mdc`, `~/.cursor/skills/_shared/developer-common/step-3-branching.md` |
| Pre-commit | `~/.cursor/skills/_shared/developer-common/step-3.5-precommit-validation.md` |
| Commit / PR | `~/.cursor/skills/_shared/developer-common/step-4-commits-pr.md`, `~/.cursor/rules/conventional-commits.mdc` |
| Pre-PR gate | `~/.cursor/skills/_shared/developer-common/step-7-checklist.md` |
| Architecture | `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md` |
| C# / tests | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` |
| Caveman Mode (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` — **Full mode** |
| Final checklist | `~/.cursor/skills/_shared/dotnet-guidelines/checklist.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

Do **not** preload `code-guidelines/languages/**` or corporate pipeline docs.

## Process

### -1. Caveman Mode

Check `~/.cursor/sdd/preferences.json`:
- If file missing → create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` → load `~/.cursor/skills/_shared/caveman/CAVEMAN.md` (Full mode rules) and display:
  > 🪨 Modo Caveman ativo (respostas compactas). Digite `caveman off` a qualquer momento para desativar.
- Honor `caveman on` / `caveman off` commands from the user at any point during the session.

### 0. Workspace

Confirm target repo (`*.sln` / `*.csproj`). Read `AGENTS.md` / `README.md`. Summarize the user request and acceptance (from issue text, PRD snippet, or user description).

### 1. Guidelines (step 0.5)

Follow `~/.cursor/skills/_shared/developer-common/step-0.5-review-guidelines.md`: load `dotnet-guidelines` files needed for this task only. Confirm test stack: **xUnit**, **Moq**, **FluentAssertions**, `Should_<Result>_When_<Condition>`.

### 2. Branch (step 3)

Baseline branch from user or repo default. Create/checkout `feature/<slug>` or `feat/<id>` — never commit on `main` / `master` / `develop`.

### 3. Plan micro-steps

List 3–7 concrete tasks (files to touch, tests to add). Stay within one session when possible; checkpoint per `context-management.mdc` (≥ 40% → pause, offer `use skill commit`).

### 4. Implement

Match existing project patterns (Glob/Read similar types first).

| Layer | Typical work |
|-------|----------------|
| Domain | Entities, value objects, domain services |
| Application | Commands/queries, handlers, validators |
| Infrastructure | EF, repositories, external clients |
| API | Endpoints, DTOs, auth filters |

Apply `clean-architecture.md` and `csharp-patterns.md` from `~/.cursor/skills/_shared/dotnet-guidelines/` while writing — do not paste full bodies into chat.

### 5. Tests

Add or update tests for changed behavior. Prefer integration tests for real flows when the project already uses them; unit tests for isolated logic.

### 6. Build and test

```bash
dotnet build
dotnet test --no-build
```

Fix failures within scope. Ask before running full-solution tests if the repo is very large.

### 7. Pre-commit (step 3.5) and handoff

Run `~/.cursor/skills/_shared/developer-common/step-3.5-precommit-validation.md` when appropriate. Offer `use skill commit` — do not commit automatically.

Before push/PR, run `~/.cursor/skills/_shared/developer-common/step-7-checklist.md` and `~/.cursor/skills/_shared/dotnet-guidelines/checklist.md`.

### 8. SDD escalation

If scope grows during work, stop and recommend:

```
use skill spec — [feature description]
# then
use skill plan — PRD/...
# then
use skill implement — PLAN/... — Step 1
```

## Must not

- ADO/MCP work items, `repo-mappings.json`, corporate pipeline or Key Vault mapping guides
- Obsolete test stacks or naming conventions (use xUnit/Moq/`Should_When_` only)
- Obsolete guideline paths (use `dotnet-guidelines/` only)
- Nested `feature/base/...` branches; commit on default integration branches
- Speculative features outside stated acceptance (YAGNI)
- Auto-commit or auto-PR without user request
- Deprecated SDD skill aliases in handoff text — use `spec`, `plan`, `implement`, `commit` only

## Handoff

| Situation | Next |
|-----------|------|
| Commit | `use skill commit` |
| Review | `use skill code-review` |
| Large scope | `use skill spec` → `plan` → `implement` |
| Next PLAN step | New chat → `use skill implement — PLAN/... — Step N` |
