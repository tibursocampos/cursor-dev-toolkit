# Guide 09: Scripts and toolkit orchestration

The `scripts/` directory contains automation, validation, and deploy tooling for cursor-dev-toolkit.

## Interactive menu: `toolkit.ps1`

```powershell
.\scripts\toolkit.ps1
```

| Option | Action |
|--------|--------|
| 1 | Sync to `~/.cursor/` (`sync-cursor.ps1`) |
| 2 | Smoke tests (`validate-all.ps1`) |
| 3 | Sync + smoke tests |
| 4 | Full validation (`-IncludeSpeckit -IncludeSessionGate`) |
| 5 | Maintainer suite (encoding, gate fix/inject) |
| 6 | SDD setup (`setup-speckit.ps1` + `configure-repo-sdd.ps1`) |
| 7 | Uninstall preview / uninstall |

## Sync: `sync-cursor.ps1`

Deploys skills, rules (`.md` -> `.mdc`), hooks, and `AGENTS.md` to `~/.cursor/`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1 -DryRun
```

- **`-KeepExtraSkills`** - do not remove custom skill folders beside the toolkit
- Mirror-deletes stale toolkit skills on sync

## Uninstall: `uninstall-toolkit.ps1`

Removes toolkit-deployed content from `~/.cursor/` (skills, rules, hooks, AGENTS.md, sessions dir).

```powershell
.\scripts\uninstall-toolkit.ps1 -DryRun
.\scripts\uninstall-toolkit.ps1
```

Does **not** remove unrelated Cursor user settings.

## Validation suite (`validation/`)

```powershell
.\scripts\validation\validate-all.ps1
.\scripts\validation\validate-all.ps1 -IncludeSpeckit -RepoPath "D:\Source\Repos\MyApp"
.\scripts\validation\validate-all.ps1 -IncludeSessionGate -RepoPath "D:\Source\Repos\MyApp"
```

| Script | Purpose |
|--------|---------|
| `validation/validate-all.ps1` | Orchestrator (run after every sync) |
| `validation/validate-toolkit-deploy.ps1` | 9 rules, hooks paths, AGENTS.md |
| `validation/validate-skills-structure.ps1` | STOP gates, line limits, manifest v2 |
| `validation/validate-impeccable-skill.ps1` | Impeccable router + reference bundle |
| `validation/validate-blip-plugin-skill.ps1` | Blip plugin skill + `blip-guidelines/` |
| `validation/validate-frontend-ecosystem.ps1` | Stack skills, guideline bundles, DESIGN-BRIEF markers |
| `validation/validate-docs-consistency.ps1` | SKILLS.md catalog vs folders |
| `validation/validate-skills-english.ps1` | Skill body language heuristic |
| `validation/validate-session-gates.ps1` | Session gate status (optional) |
| `validation/validate-speckit-init.ps1` | `.specify/` integrity (optional) |

## Maintainer utilities (`maintainers/`)

| Script | Purpose |
|--------|---------|
| `maintainers/normalize-skill-encoding.ps1` | Fix mojibake in markdown |
| `maintainers/inject-skill-gates.ps1` | Add STOP blocks to skills missing them |
| `maintainers/fix-skill-gates.ps1` | Remove duplicate STOP blocks |
| `maintainers/migrate-manifest-v2.ps1` | Upgrade legacy SDD manifest |
| `maintainers/rename-skill-refs.ps1` | Bulk skill name migration |
| `maintainers/fix-speckit-refs.ps1` | Fix over-aggressive speckit renames |
| `maintainers/fix-encoding-and-skill-names.ps1` | Combined encoding + name fixes |
| `maintainers/fix-legacy-display-names.ps1` | Legacy display name migration |
| `maintainers/fix_mojibake.py` | Python mojibake helper |

## SDD setup (root)

| Script | Purpose |
|--------|---------|
| `setup-speckit.ps1` | Spec Kit CLI prerequisites |
| `configure-repo-sdd.ps1` | Register repo in manifest v2 |

See `scripts/README.md` for the full layout (`validation/`, `maintainers/`, `_lib/`).

## Recommended workflow after changes

1. Edit skills/rules in repo
2. `.\scripts\sync-cursor.ps1`
3. `.\scripts\validation\validate-all.ps1`
4. Restart Cursor if hooks changed
