---
name: test-coverage
description: Run .NET test coverage (Coverlet), report metrics aligned with SonarQube (new code, branch, per-file), and evaluate against a threshold (default 80%). Use when the user says "use skill test-coverage", "coverage report", or "/coverage". Git-only — no Sonar server required.
---

# Skill: test-coverage

## Trigger

Invoke when the user asks for: `use skill test-coverage`, `coverage report`, `/coverage`, or when a PLAN step / `code-review` requires coverage evidence.

**Arguments (optional):**

| Input | Meaning |
|-------|---------|
| Base branch | `main`, `develop` — ask once if missing (same as `code-review`) |
| Test project path | `path/to/Tests.csproj` — auto-detect `*Tests.csproj` / `*.Tests.csproj` if omitted |
| Threshold | Minimum line coverage on **changed production `.cs` files** (default: **80**) |
| Target | **100** — aspirational; document gaps when below 100 but ≥ threshold |

## Outcome

A structured **coverage report** in **pt-BR** with:

- **Coverage on new code** — line coverage on changed production files vs base branch
- **Overall branch coverage** — solution-wide line coverage after tests
- **Per-file breakdown** — each changed production file with line %
- **Decision:** Pass (≥ threshold) or Fail (&lt; threshold) with gap list

Does not modify code unless the user asks for test additions in a follow-up.

## Lazy-load

| When | Path |
|------|------|
| Commands, parsing, exclusions | `skills/test-coverage/reference.md` or `~/.cursor/skills/test-coverage/reference.md` after sync |
| Add tests for gaps | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` |
| Commit | `use skill commit` |

## Process

### 0. Workspace

Confirm **target .NET repository** (`.sln` or `*Tests.csproj`). If the workspace is `cursor-dev-toolkit` only (no test projects), stop and ask which consumer repo to open.

Detect stack; read `AGENTS.md` / `README.md` when present.

### 1. Resolve scope

**Base branch:** user argument, or `main` / `develop` (ask once if ambiguous).

```bash
git fetch origin   # when remote comparison is needed
git rev-parse --abbrev-ref HEAD
git diff <base>...HEAD --name-only -- "*.cs"
```

Filter to **production** changed files per `reference.md` § Exclusions. Record the list for per-file metrics.

### 2. Prerequisites check

Before running tests, verify per `reference.md` § Prerequisites:

- `coverlet.collector` on test project(s)
- `dotnet test` succeeds
- `reportgenerator` global tool (install once if missing)

If `coverlet.collector` is missing, stop with install instructions — do not fail silently.

### 3. Collect coverage

Run `dotnet test` with Coverlet collector and generate reports per `reference.md` § Commands.

Use scoped test project when the repo is large or user provided a path.

### 4. Compute metrics

Parse Cobertura / ReportGenerator output per `reference.md` § Metrics:

| Metric | Definition |
|--------|------------|
| **New code** | Weighted line coverage on changed production `.cs` files |
| **Overall branch** | Line coverage across included assemblies |
| **Per-file** | Line % per changed production file |

Exclude migrations, generated code, and test projects from **new code** denominator (see reference).

### 5. Evaluate threshold

| Result | When |
|--------|------|
| **Pass** | New code coverage ≥ threshold (default 80%) |
| **Fail** | New code coverage &lt; threshold |

Always note distance to **target 100%** for files below 100% even when Pass.

### 6. Write report

Use the template in `reference.md`. Include:

- Commands run and any limitations (partial test run, missing coverlet)
- Approval block for `code-review` when Pass
- Gap list (file + % + uncovered line hints when available) when Fail

### 7. Handoff

| Situation | Next |
|-----------|------|
| Pass | `use skill code-review` — paste approval block from report |
| Fail — add tests | `use skill dotnet-developer` or `use skill implement` |
| Build/test broken | `use skill fix-build` |
| Commit coverage tooling in consumer repo | `use skill commit` |

## Must not

- Require SonarLint, Visual Studio, SonarQube login, or corporate pipeline APIs
- Auto-commit, auto-push, or add tests without user request
- Claim Pass when tests did not run or coverlet output is missing
- Count EF migrations, `*.g.cs`, or `*.Designer.cs` in new-code denominator
- Block merge by itself — gate is informational unless PRD/PLAN/`code-review` applies threshold

## Handoff

| Situation | Next |
|-----------|------|
| SDD feature with PLAN | Last PLAN step or `code-review` after all implement steps |
| Small fix | `use skill dotnet-developer` to raise coverage, then re-run this skill |
