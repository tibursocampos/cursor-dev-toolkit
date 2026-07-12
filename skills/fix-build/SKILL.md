---
name: fix-build
description: Diagnose and fix failing dotnet build or test runs. Local first; optional GitHub Actions via gh. Use when fixing a build or invoking /fix-build.
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

# Skill: fix-build

## Trigger

Invoke when the user asks for: `/fix-build`, `fix build`, `/fix-build`, or when build/test failures block progress.

**Arguments (optional):**

| Input | Meaning |
|-------|---------|
| (none) | Run local `dotnet build` / `dotnet test` in the open workspace |
| Pasted log | Analyze the log text the user provides |
| `gh` context | User names a failed workflow run - use `gh` per `reference.md` section CI (optional) |

Do not require a build ID from Azure Pipelines or any PAT.

## Outcome

Structured diagnosis, proposed fixes with rationale, fixes applied only after user confirmation, local re-validation, then handoff to `/commit` if the user wants to commit.

## Lazy-load

| When | Path |
|------|------|
| Locale / timezone / Bogus heuristics | `skills/fix-build/reference.md` or `~/.cursor/skills/fix-build/reference.md` after sync |
| C# patterns | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` |
| Caveman Mode (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` - **Full mode** |
| Commit | `/commit` |

## Process

### -1. Caveman Mode

Check `~/.cursor/sdd/preferences.json`:
- If file missing -> create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` -> load `~/.cursor/skills/_shared/caveman/CAVEMAN.md` (Full mode rules) and display:
  > [Caveman] Modo Caveman ativo (respostas compactas). Digite `caveman off` a qualquer momento para desativar.
- Honor `caveman on` / `caveman off` commands from the user at any point during the session.

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

**GitHub Actions (optional):** if user points to a run and `gh` is available, fetch logs per `reference.md` section CI. Skip if unavailable - stay on local reproduction.

### 2. Structured diagnosis

Present:

```
## Build diagnosis

**Source:** local | pasted log | GitHub Actions
**Branch:** <current branch>
**Failures:** N

### Items
1. [<category>] <summary> - <file>:<line> or <test name>
...
```

Categories: compile, restore/NuGet, test assertion, configuration, pipeline config (YAML only if user supplied log).

### 3. Root-cause investigation

For each item, Read/Grep the codebase. Apply heuristics in `reference.md` section Common causes (culture, timezone, Bogus seed, fixture order, glob in CI YAML).

Load `csharp-patterns.md` only when editing production or test code.

### 4. Propose fixes

List each change: file, problem, cause, proposed fix. **Wait for user confirmation** before Edit/Write.

### 5. Apply and validate

After approval, apply minimal diffs. Re-run:

```bash
dotnet build
dotnet test --no-build
```

Or scoped test filter when the repo is large (see `reference.md` section Scoped test).

### 6. Handoff

When build and targeted tests pass, offer:

```
/commit
```

Do not auto-commit. Do not push unless the user asks via commit skill or explicitly.

## Must not

- Azure DevOps REST, PAT, `dev.azure.com`, Credential Manager ADO entries, or corporate org URLs
- Mandatory external CI API - local reproduction is enough
- Auto-commit or auto-push
- Corporate agent pool names or private feed assumptions without repo evidence

## Handoff

| Situation | Next |
|-----------|------|
| Commit on valid branch | `/commit` |
| New EF migration needed | `/add-migrations` |
| Large feature scope | `/sdd-spec` -> `sdd-plan` -> `sdd-develop` |
