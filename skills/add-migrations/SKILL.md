---
name: add-migrations
description: Add an EF Core migration in the open workspace. Discovers startup project, DbContext, and migrations folder via Glob/Grep. Use when the user says "use skill add-migrations", "add migration", or "/add-migrations". Optional migration name in the invocation.
---

# Skill: add-migrations

## Trigger

Invoke when the user asks for: `use skill add-migrations`, `add migration`, `/add-migrations`, or when a PLAN step requires a new EF Core migration.

Optional argument: migration name in **PascalCase**. If omitted, infer from pending model changes and confirm with the user.

## Outcome

A new EF Core migration in the **target workspace** (not `cursor-dev-toolkit` unless that repo has a `DbContext`). User sees detected projects, final migration name, and created file paths.

## Lazy-load

| When | Path |
|------|------|
| EF tool install / version notes | `skills/add-migrations/reference.md` (this repo) or `~/.cursor/skills/add-migrations/reference.md` after sync |
| .NET layering | `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md` |

## Process

### 0. Workspace

Confirm the **target .NET repository** (`.sln` or `*.csproj` with `DbContext`). If the workspace is the toolkit only, stop and ask which repo to open.

### 1. Discover project layout

Use **Glob** and **Grep** (not hardcoded paths). Full checklist: `reference.md` § Discovery.

Summarize before running `dotnet ef`:

| Setting | Detected value |
|---------|----------------|
| Solution root | path to `.sln` or repo root |
| Startup project | API/Host/Web/Worker with `Program.cs` |
| Target project | `.csproj` containing `DbContext` |
| DbContext class | e.g. `ApplicationDbContext` |
| Migrations folder | existing `Migrations/` or default under target |

If any value is ambiguous, ask the user once.

### 2. Migration name

- **Name provided:** normalize to PascalCase.
- **Name omitted:** inspect `git diff` / `git status`, infer from entity/schema changes (see `reference.md` § Naming), present suggestion, wait for confirmation.

### 3. Ensure `dotnet-ef`

```bash
dotnet ef --version
```

If missing, follow `reference.md` § EF tool (global or local tool-path; no fixed version in this skill body).

### 4. Add migration

From solution root:

```bash
dotnet ef migrations add <MigrationName> -s <StartupProject> -p <TargetProject> -c <DbContext>
```

Use `./dotnet-ef` instead of `dotnet ef` when a repo-local tool is documented in `reference.md` or repo README.

### 5. Verify and summarize

Confirm new `*.cs` + `*.Designer.cs` and updated `*ModelSnapshot.cs` under the migrations folder. Optionally note how to apply locally (`database update` — details in `reference.md`).

## Must not

- Hardcode EF tool package versions in `SKILL.md` (use `reference.md`)
- Assume corporate feeds, Azure DevOps, or organization-specific URLs
- Run migrations against production without explicit user request
- Modify `cursor-dev-toolkit` when the user intended a consumer repo

## Handoff

| Situation | Next |
|-----------|------|
| PLAN step with EF | Continue `use skill implement — <full-plan-path> — Step N` (path from implement handoff; SDD locations per `STORAGE.md`) |
| Build/test failures after migration | `use skill fix-build` |
| Commit | `use skill commit` |
