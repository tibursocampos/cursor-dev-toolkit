# Documentation index

| Document | Audience | Purpose |
|----------|----------|---------|
| [INSTALL.md](INSTALL.md) | **Start here** | Install, sync, troubleshooting |
| [guides/README.md](guides/README.md) | **Daily usage** | Decision tree, step-by-step skill manuals (guides 01–05) |
| [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md) | Maintainers | Repository layout, deploy, extension checklist |
| [HOOKS.md](HOOKS.md) | Optional hooks users | Hook behavior, limits, smoke tests |
| [TOKEN_BUDGET.md](TOKEN_BUDGET.md) | Toolkit builders | Token/cost guidance when extending content |
| [../skills/test-coverage/SKILL.md](../skills/test-coverage/SKILL.md) | Skill users | Coverage workflow (`use skill test-coverage`) and threshold behavior |

**Related (repo root):**

| Path | Purpose |
|------|---------|
| [../README.md](../README.md) | Project overview and quick links |
| [../AGENTS.md](../AGENTS.md) | Agent router (installed to `~/.cursor/AGENTS.md`) |

SDD PRD/PLAN artifacts are **local only** — `.gitignore` must include `/PRD/`, `/PLAN/`, `/docs/PRD/`, and `/docs/PLAN/` at repo root (applied by `spec` / `plan` per `STORAGE.md`). Pipeline guards: `PIPELINE.md` and `~/.cursor/rules/sdd-pipeline-guards.mdc`.

For invokes, examples, and common mistakes, use **[guides/README.md](guides/README.md)** instead of reading `SKILL.md` files directly.
