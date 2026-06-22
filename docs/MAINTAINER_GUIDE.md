# Maintainer guide - cursor-dev-toolkit

Reference for repository layout, deploy, validation, and conventions.

| Field | Value |
|-------|--------|
| **Install target** | `~/.cursor/` via `scripts/sync-cursor.ps1` |
| **Smoke test** | `scripts/validate-all.ps1` after sync |
| **Skills catalog** | [docs/SKILLS.md](SKILLS.md) |

## Repository layout

```
cursor-dev-toolkit/
├── AGENTS.md
├── README.md
├── docs/                    # INSTALL, SKILLS, ENFORCEMENT, guides/
├── rules/                   # -> ~/.cursor/rules/*.mdc (incl. guardrails.md)
├── hooks/
├── scripts/                 # sync, validate-*, setup-speckit, configure-repo-sdd
└── skills/                  # -> ~/.cursor/skills/
    ├── sdd-spec/, sdd-plan/, sdd-develop/
    ├── speckit-setup/ … speckit-develop/
    ├── developer/, code-review/, commit/, push/, …
    └── _shared/             # sdd-artifacts, guidelines, validators
```

## Skills (25 folders)

See [SKILLS.md](SKILLS.md). Naming: **kebab-case** folders and `use skill <name>`.

## Deploy and validate

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
.\scripts\validate-all.ps1
```

## Checklist: new skill or rule

1. **English** - SKILL.md body in English; user prompts may be pt-BR.
2. **Gate block** - copy from `skills/_shared/SKILL_TEMPLATE.md` or run `inject-skill-gates.ps1`.
3. **Size policy** - `SKILL.md` hard limit **500 lines** (Cursor / Agent Skills standard). STOP gate (~27 lines) is fixed overhead. Soft targets by tier: speckit workflow 150-180; SDD classic 115-135; review/coverage 150-170; atomic ops (`push`) 90-110. Use `reference.md` for long templates and encyclopedic checklists; keep decision tables, must-not, and resolution gates in `SKILL.md`. See [TOKEN_BUDGET.md](TOKEN_BUDGET.md).
4. **Catalog** - add entry to `docs/SKILLS.md`.
5. **Sync + validate** - `sync-cursor.ps1` then `validate-all.ps1`.

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

## Maintenance scripts

| Script | Purpose |
|--------|---------|
| `rename-skill-refs.ps1` | Bulk skill name migration |
| `fix-speckit-refs.ps1` | Fix over-aggressive speckit renames |
| `inject-skill-gates.ps1` | Add STOP blocks |
| `fix-skill-gates.ps1` | Remove duplicate STOP blocks |
| `normalize-skill-encoding.ps1` | Fix encoding in skills |
| `migrate-manifest-v2.ps1` | Upgrade legacy manifest |
