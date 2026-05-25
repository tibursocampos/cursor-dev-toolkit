# cursor-dev-toolkit

Personal Cursor IDE agent toolkit: SDD workflow, .NET guidelines, Git-only developer flow, and optional hooks. Neutral branding — no work-item tracker or corporate pipeline integrations.

**MVP status:** 14/14 PLAN steps complete. Deploy with `scripts/sync-cursor.ps1`.

## What this is

| Capability | Description |
|------------|-------------|
| **SDD workflow** | `spec` → `plan` → `implement` with PRD/PLAN in the repo or `~/.cursor/sdd/<repo-id>/` |
| **.NET guidelines** | `dotnet-guidelines` (Clean Architecture, xUnit, Moq, FluentAssertions) |
| **Git-only flow** | Branching, commits, checklist — no Azure DevOps |
| **Cursor-native** | Sync to `~/.cursor/` (skills, rules, hooks, router) |

## Quick start

1. Clone this repo.
2. Follow **[docs/INSTALL.md](docs/INSTALL.md)** (install, verify, use SDD in any project).
3. One-liner deploy (from repo root):

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
   ```

4. In any project chat: `use skill spec` → `use skill plan` → `use skill implement — <plan-path> — Step N` (repo or global storage).

Re-run sync after pulling toolkit updates (idempotent).

## Documentation

| Doc | Content |
|-----|---------|
| [docs/INSTALL.md](docs/INSTALL.md) | **Install and usage** (step-by-step) |
| [docs/README.md](docs/README.md) | Documentation index |
| [docs/HOOKS.md](docs/HOOKS.md) | Optional hooks (behavior, limits) |
| [docs/MAINTAINER_GUIDE.md](docs/MAINTAINER_GUIDE.md) | Repository layout and maintainer checklist |
| [docs/TOKEN_BUDGET.md](docs/TOKEN_BUDGET.md) | Token/cost guidance |
| [AGENTS.md](AGENTS.md) | Agent router (synced to `~/.cursor/`) |
| [PLAN/PLAN_001_cursor_dev_toolkit.md](PLAN/PLAN_001_cursor_dev_toolkit.md) | Build plan (completed) |

## Repository layout

```
cursor-dev-toolkit/
├── AGENTS.md
├── README.md
├── PRD/
├── PLAN/
├── docs/                  # INSTALL, HOOKS, MAINTAINER_GUIDE, TOKEN_BUDGET
├── rules/                 # → ~/.cursor/rules/*.mdc
├── hooks/                 # → ~/.cursor/hooks/ + merge hooks.json
├── scripts/               # sync-cursor.ps1
└── skills/                # → ~/.cursor/skills/
```

## Conventions

| Area | Rule |
|------|------|
| Skill names | English, kebab-case (`spec`, `plan`, `implement`) |
| SDD agent artifacts (PRD, PLAN `.md`) | Brazilian Portuguese (pt-BR) — `rules/sdd-artifact-language-pt-br.md` |
| Production code & tests | English; tests `Should_<Result>_When_<Condition>` |
| Project docs (`docs/`, README deliverables) | Ask pt-BR or English in skill |
| Test stack | xUnit + Moq + FluentAssertions |
| User chat replies | Brazilian Portuguese (pt-BR) — `rules/user-language-pt-br.md` |

## Rules (after sync)

| Source | Installed | When |
|--------|-----------|------|
| `rules/conventional-commits.md` | `~/.cursor/rules/conventional-commits.mdc` | Every commit |
| `rules/branch-validation.md` | `~/.cursor/rules/branch-validation.mdc` | Before commit/push |
| `rules/context-management.md` | `~/.cursor/rules/context-management.mdc` | Multi-step SDD |
| `rules/user-language-pt-br.md` | `~/.cursor/rules/user-language-pt-br.mdc` | Always pt-BR in chat |
| `rules/sdd-artifact-language-pt-br.md` | `~/.cursor/rules/sdd-artifact-language-pt-br.mdc` | PRD/PLAN `.md` in pt-BR; code always English |

Branches: `feature/<slug>` or `feat/<id>` only — not `main`, `master`, or `develop`.

## License

Personal use.
