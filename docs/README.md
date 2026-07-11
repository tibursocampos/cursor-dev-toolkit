# Documentation index

| Document | Audience | Purpose |
|----------|----------|---------|
| [INSTALL.md](INSTALL.md) | **Start here** | Install, sync, uninstall, troubleshooting |
| [guides/README.md](guides/README.md) | **Daily usage** | Decision tree, step-by-step skill manuals (guides 01-10) |
| [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md) | Maintainers | Repository layout, deploy, extension checklist |
| [HOOKS.md](HOOKS.md) | Optional hooks users | Hook behavior, limits, smoke tests |
| [TOKEN_BUDGET.md](TOKEN_BUDGET.md) | Toolkit builders | Token/cost guidance when extending content |
| [architecture.md](architecture.md) | Maintainers | Cursor deployment model (rules, hooks, sync) |
| [shared-guidelines.md](shared-guidelines.md) | Skill authors | Index of `_shared/` guideline packs |
| [SKILLS.md](SKILLS.md) | All users | Canonical skill catalog (38 skills) |
| [impeccable-integration.md](impeccable-integration.md) | Frontend / design | Impeccable -> DESIGN-BRIEF -> stack developer |
| [blip-plugin-integration.md](blip-plugin-integration.md) | Blip plugin authors | Scaffold, profiles, handoff, anti-patterns |
| [../skills/test-coverage/SKILL.md](../skills/test-coverage/SKILL.md) | Skill users | Coverage workflow (`use skill test-coverage`) |
| [SYNC_POLICY.md](SYNC_POLICY.md) | Maintainers | Cross-toolkit sync with antigravity-dev-toolkit |

**Related (repo root):**

| Path | Purpose |
|------|---------|
| [../README.md](../README.md) | Project overview and quick links |
| [../AGENTS.md](../AGENTS.md) | Agent router (installed to `~/.cursor/AGENTS.md`) |

SDD artifacts are **local only** - `.gitignore` must include `/features/` (canonical Classic / Forma C tree). `/PRD/` and `/PLAN/` remain as a **safety net** only (not write destinations). Pipeline guards: `PIPELINE.md` and `~/.cursor/rules/sdd-pipeline-guards.mdc`.

For invokes, examples, and common mistakes, use **[guides/README.md](guides/README.md)** instead of reading `SKILL.md` files directly.
