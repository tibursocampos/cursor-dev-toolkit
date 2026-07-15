# Maintainer guide - cursor-dev-toolkit

Reference for repository layout, deploy, validation, and conventions.

| Field | Value |
|-------|--------|
| **Install target** | `~/.cursor/` via `scripts/sync-cursor.ps1` |
| **Smoke test** | `scripts/validation/validate-all.ps1` after sync |
| **Skills catalog** | [docs/SKILLS.md](SKILLS.md) |

## Repository layout

```
cursor-dev-toolkit/
├── AGENTS.md
├── README.md
├── docs/                    # INSTALL, SKILLS, ENFORCEMENT, guides/
├── rules/                   # -> ~/.cursor/rules/*.mdc (incl. guardrails.md)
├── hooks/
├── scripts/                 # sync, toolkit.ps1, uninstall, validation/, maintainers/
└── skills/                  # -> ~/.cursor/skills/
    ├── sdd-spec/, sdd-plan/, sdd-develop/
    ├── orchestrate-analyze/, orchestrate-deliver/, orchestrate-develop/  # Forma C
    ├── memory-bank-init/    # Forma C Step 0 (optional for Forma A)
    ├── developer/, dotnet-developer/, react-developer/, react-native-developer/, blip-plugin-developer/, … stack skills
    ├── impeccable/          # Frontend design router
    ├── code-review/, commit/, push/, …
    └── _shared/             # sdd-artifacts, agents/, templates/features|memory-bank/, guidelines, …
```

## Skills (34 folders)

See [SKILLS.md](SKILLS.md). Naming: **kebab-case** folders and `/<name>`.

**Forma C (O1/O2/O3):** Step 0 memory-bank -> `orchestrate-analyze` -> `orchestrate-deliver` -> `orchestrate-develop` (Step N refresh-light). Skill `memory-bank-init` for manual create/refresh/refresh-light. Guide: [guides/10-forma-c-orquestracao.md](guides/10-forma-c-orquestracao.md). End-to-end cases: [11 NuGet](guides/11-forma-c-caso-nuget-extract.md), [12 mobile](guides/12-forma-c-caso-mobile-app.md). Classic layout: `features/NNN-slug/` + co-located `memory-bank/` (templates under `skills/_shared/templates/`).

**Frontend / Blip:** `impeccable` (design router), `blip-plugin-developer` (new Blip extension scaffold). Shared packs: `blip-guidelines/`, `react-guidelines/`, `frontend-guidelines/`. Integration docs: [impeccable-integration.md](impeccable-integration.md), [blip-plugin-integration.md](blip-plugin-integration.md).

## Deploy and validate

After changing skills, rules, or Forma C templates:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
.\scripts\validation\validate-all.ps1
```

Or: `.\scripts\toolkit.ps1` (interactive menu). `validate-skills-structure.ps1` asserts O1/O2/O3 folders and `templates/features/` + `agents/` artifacts.

## Checklist: new skill or rule

1. **English** - SKILL.md body in English; user prompts may be pt-BR.
2. **Gate block** - copy from `skills/_shared/SKILL_TEMPLATE.md` or run `inject-skill-gates.ps1`.
3. **Size policy** - `SKILL.md` hard limit **500 lines** (Cursor / Agent Skills standard). STOP gate (~27 lines) is fixed overhead. Soft targets by tier: SDD classic 115-135; review/coverage 150-170; atomic ops (`push`) 90-110. Use `reference.md` for long templates and encyclopedic checklists; keep decision tables, must-not, and resolution gates in `SKILL.md`. See [TOKEN_BUDGET.md](TOKEN_BUDGET.md).
4. **Catalog** - add entry to `docs/SKILLS.md` and update [guides/README.md](guides/README.md) quick reference when user-facing.
5. **Integration doc** - for ecosystem skills (e.g. `impeccable`, `blip-plugin-developer`), add or extend `docs/*-integration.md`.
6. **Sync + validate** - `sync-cursor.ps1` then `validate-all.ps1`.

## SKILL.md vs reference.md

| Keep in SKILL.md | Move to reference.md |
|------------------|---------------------|
| Outcome, triggers, process steps | Full markdown templates (optional duplicate) |
| Decision / resolution / escalation tables | Extensive .NET checklists (`dotnet-guidelines`) |
| Must-not, handoff | Long examples, optional heuristics |
| Explicit hooks: "Before step N, Read reference.md section X" | Stack detection detail tables |


Path: `~/.cursor/sdd/manifest.json` - `schema_version: 2`, per-repo `classic` section (legacy `speckit` keys ignored). See `skills/_shared/sdd-artifacts/STORAGE.md`.

## Session gates

See `skills/_shared/sdd-artifacts/SESSION.md`.

| Scope | Path | Gates |
|-------|------|-------|
| Repo | `~/.cursor/sdd/sessions/{repo-hash}.json` | `storage_confirmed`, `write_confirmed` |
| Develop (PLAN) | `~/.cursor/sdd/sessions/{repo-hash}/plan-{plan-hash}.json` | `step_confirmed`, `tests_run` |
| Develop (PLAN+step) | `~/.cursor/sdd/sessions/{repo-hash}/plan-{plan-hash}-step-{N}.json` | same (parallel O3 on one PLAN) |

Develop gates always require `-PlanPath` in `validate-session-gates.ps1`. New scoped files start with gates `false` - never copy develop gates from the flat repo JSON.

## Maintenance scripts (`maintainers/`)

| Script | Purpose |
|--------|---------|
| `maintainers/rename-skill-refs.ps1` | Bulk skill name migration |
| `maintainers/inject-skill-gates.ps1` | Add STOP blocks |
| `maintainers/fix-skill-gates.ps1` | Remove duplicate STOP blocks |
| `maintainers/normalize-skill-encoding.ps1` | Fix encoding in skills |
| `maintainers/migrate-manifest-v2.ps1` | Upgrade legacy manifest |

See `scripts/README.md` for the full layout.
