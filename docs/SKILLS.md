# Skills catalog - cursor-dev-toolkit

Canonical kebab-case skill folders under `skills/`. Invoke with `use skill <name>` or `/<name>`.

## Classic SDD

| Skill | Purpose |
|-------|---------|
| `sdd-spec` | Create PRD (pt-BR default) |
| `sdd-plan` | Baby-step PLAN from PRD |
| `sdd-develop` | Execute one PLAN step per session |

## Spec Kit

| Skill | Purpose |
|-------|---------|
| `speckit-setup` | Install Spec Kit CLI prerequisites |
| `speckit-init` | Initialize `.specify/` + constitution |
| `speckit-spec` | Create `spec.md` under `.specify/specs/` |
| `speckit-plan` | Generate `plan.md` and `tasks.md` |
| `speckit-develop` | Implement one `tasks.md` item per session |

## Developer and operational

| Skill | Purpose |
|-------|---------|
| `developer` | Small/medium work without full SDD |
| `code-review` | Structured review vs PRD/PLAN |
| `fix-build` | Diagnose/fix build and tests |
| `test-coverage` | .NET Coverlet coverage report |
| `commit` | Conventional commit on valid branch |
| `push` | Safe git push after confirmation |
| `add-migrations` | EF Core migration discovery |
| `create-message-consumer` | Message consumer scaffold |
| `refactor` | Safe incremental refactoring |
| `api-integrate` | Typed API clients from OpenAPI |
| `performance-profile` | Profiling and optimization |
| `containerize` | Dockerfiles and compose |
| `i18n-manager` | Extract strings to resource files |

## Documentation (RAG)

| Skill | Purpose |
|-------|---------|
| `document-plan` | Baby-step documentation plan |
| `document-implement` | Execute one doc plan step |

## Backlog prep

| Skill | Purpose |
|-------|---------|
| `refine-backlog-item` | Refine backlog item + BDD scorecard |
| `breakdown-tasks` | Grouped implementation checklist |

## Post-sync validation

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validate-all.ps1
```

See [ENFORCEMENT.md](ENFORCEMENT.md) and [INSTALL.md](INSTALL.md).
