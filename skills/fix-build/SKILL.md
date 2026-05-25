---
name: fix-build
description: Diagnose and fix failing dotnet build or test runs in the open workspace. Local first; optional GitHub Actions logs via gh. Use when the user says "use skill fix-build", "fix build", or "/fix-build". Git-only commit handoff — no Azure DevOps API.
---

# Skill: fix-build

## Trigger

Invoke when the user asks for: `use skill fix-build`, `fix build`, `/fix-build`, or when build/test failures block progress.

**Arguments (optional):**

| Input | Meaning |
|-------|---------|
| (none) | Run local `dotnet build` / `dotnet test` in the open workspace |
| Pasted log | Analyze the log text the user provides |
| `gh` context | User names a failed workflow run — use `gh` per `reference.md` § CI (optional) |

Do not require a build ID from Azure Pipelines or any PAT.

## Outcome

Structured diagnosis, proposed fixes with rationale, fixes applied only after user confirmation, local re-validation, then handoff to `use skill commit` if the user wants to commit.

## Lazy-load

| When | Path |
|------|------|
| Locale / timezone / Bogus heuristics | `skills/fix-build/reference.md` or `~/.cursor/skills/fix-build/reference.md` after sync |
| C# patterns | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` |
| Commit | `use skill commit` |

## Process

### 0. Workspace

Confirm **target repository** (`.sln` or test projects). Summarize failure source: local run, pasted CI log, or optional `gh run view`.

### 1. Collect failure evidence

**Local (default):**

```bash
dotnet build
dotnet test --no-build
```

Capture errors: file, line, test name, expected vs actual.

**Pasted log:** extract compile errors, restore failures, and test failures (`[FAIL]`, `Error Message`, `Expected`/`Actual`).

**GitHub Actions (optional):** if user points to a run and `gh` is available, fetch logs per `reference.md` § CI. Skip if unavailable — stay on local reproduction.

### 2. Structured diagnosis

Present:

```
## Build diagnosis

**Source:** local | pasted log | GitHub Actions
**Branch:** <current branch>
**Failures:** N

### Items
1. [<category>] <summary> — <file>:<line> or <test name>
...
```

Categories: compile, restore/NuGet, test assertion, configuration, pipeline config (YAML only if user supplied log).

### 3. Root-cause investigation

For each item, Read/Grep the codebase. Apply heuristics in `reference.md` § Common causes (culture, timezone, Bogus seed, fixture order, glob in CI YAML).

Load `csharp-patterns.md` only when editing production or test code.

### 4. Propose fixes

List each change: file, problem, cause, proposed fix. **Wait for user confirmation** before Edit/Write.

### 5. Apply and validate

After approval, apply minimal diffs. Re-run:

```bash
dotnet build
dotnet test --no-build
```

Or scoped test filter when the repo is large (see `reference.md` § Scoped test).

### 6. Handoff

When build and targeted tests pass, offer:

```
use skill commit
```

Do not auto-commit. Do not push unless the user asks via commit skill or explicitly.

## Must not

- Azure DevOps REST, PAT, `dev.azure.com`, Credential Manager ADO entries, or corporate org URLs
- Mandatory external CI API — local reproduction is enough
- Auto-commit or auto-push
- Corporate agent pool names or private feed assumptions without repo evidence

## Handoff

| Situation | Next |
|-----------|------|
| Commit on valid branch | `use skill commit` |
| New EF migration needed | `use skill add-migrations` |
| Large feature scope | `use skill spec` → `plan` → `implement` |
