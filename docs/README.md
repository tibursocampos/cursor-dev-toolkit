# Documentation index

| Document | Audience | Purpose |
|----------|----------|---------|
| [INSTALL.md](INSTALL.md) | **Start here** | Install, sync, daily usage, troubleshooting |
| [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md) | Maintainers | Repository layout, deploy, extension checklist |
| [HOOKS.md](HOOKS.md) | Optional hooks users | Hook behavior, limits, smoke tests |
| [TOKEN_BUDGET.md](TOKEN_BUDGET.md) | Toolkit builders | Token/cost guidance when extending content |

**Related (repo root):**

| Path | Purpose |
|------|---------|
| [../README.md](../README.md) | Project overview and quick links |
| [../AGENTS.md](../AGENTS.md) | Agent router (installed to `~/.cursor/AGENTS.md`) |

SDD PRD/PLAN artifacts are **local only** — `.gitignore` must include `/PRD/`, `/PLAN/`, `/docs/PRD/`, and `/docs/PLAN/` at repo root (applied by `spec` / `plan` per `STORAGE.md`). Rules after sync: `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md`.
