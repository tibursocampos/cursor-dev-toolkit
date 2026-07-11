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
    ├── speckit-setup/ … speckit-develop/
    ├── developer/, dotnet-developer/, react-developer/, blip-plugin-developer/, … stack skills
    ├── impeccable/          # Frontend design router
    ├── code-review/, commit/, push/, …
    └── _shared/             # sdd-artifacts, agents/, templates/features/, guidelines, …
```

## Skills (38 folders)

See [SKILLS.md](SKILLS.md). Naming: **kebab-case** folders and `use skill <name>`.

**Forma C (O1/O2/O3):** `orchestrate-analyze`, `orchestrate-deliver`, `orchestrate-develop`. Guide: [guides/10-forma-c-orquestracao.md](guides/10-forma-c-orquestracao.md). Classic layout: `features/NNN-slug/` (templates under `skills/_shared/templates/features/`).

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
3. **Size policy** - `SKILL.md` hard limit **500 lines** (Cursor / Agent Skills standard). STOP gate (~27 lines) is fixed overhead. Soft targets by tier: speckit workflow 150-180; SDD classic 115-135; review/coverage 150-170; atomic ops (`push`) 90-110. Use `reference.md` for long templates and encyclopedic checklists; keep decision tables, must-not, and resolution gates in `SKILL.md`. See [TOKEN_BUDGET.md](TOKEN_BUDGET.md).
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


Path: `~/.cursor/sdd/manifest.json` - `schema_version: 2`, per-repo `classic` + `speckit` sections. See `skills/_shared/sdd-artifacts/STORAGE.md`.

## Session gates

Path: `~/.cursor/sdd/sessions/{repo-hash}.json` - see `SESSION.md`.

## Maintenance scripts (`maintainers/`)

| Script | Purpose |
|--------|---------|
| `maintainers/rename-skill-refs.ps1` | Bulk skill name migration |
| `maintainers/fix-speckit-refs.ps1` | Fix over-aggressive speckit renames |
| `maintainers/inject-skill-gates.ps1` | Add STOP blocks |
| `maintainers/fix-skill-gates.ps1` | Remove duplicate STOP blocks |
| `maintainers/normalize-skill-encoding.ps1` | Fix encoding in skills |
| `maintainers/migrate-manifest-v2.ps1` | Upgrade legacy manifest |

See `scripts/README.md` for the full layout.
