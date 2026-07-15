# Guide 09: Scripts and toolkit orchestration

The `scripts/` directory contains automation, validation, and deploy tooling for cursor-dev-toolkit.

Option **3** runs sync and smoke tests in the **current PowerShell session** (not a child process), prints a step banner after sync, then runs `validate-all.ps1`. A workflow summary shows `PASS` / `FAIL` / `SKIP` per step.

Option **4** passes `-RepoPath` to the toolkit repo root automatically.

## Interactive menu: `toolkit.ps1`

```powershell
.\scripts\toolkit.ps1
```

| Option | Action |
|--------|--------|
| 1 | Sync to `~/.cursor/` (`sync-cursor.ps1`) |
| 2 | Smoke tests (`validate-all.ps1`) |
| 3 | Sync + smoke tests |
| 4 | Full validation (`-IncludeSessionGate`) |
| 5 | Maintainer suite (encoding, gate fix/inject) |
| 6 | Configure SDD for **toolkit repo** (`configure-repo-sdd.ps1 -RepoPath <toolkit>`) |
| 7 | Uninstall preview / uninstall |

## Sync: `sync-cursor.ps1`

Deploys skills, rules (`.md` -> `.mdc`), hooks, and `AGENTS.md` to `~/.cursor/`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1 -DryRun
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1 -PruneStaleSkills
```

- **Default:** preserves custom/extra skill folders under `~/.cursor/skills` that are not in the toolkit repo
- **`-PruneStaleSkills`** - opt-in mirror prune of those extras (removes skills absent from the toolkit)
- **`-KeepExtraSkills`** - deprecated alias of the default (still accepted; wins over `-PruneStaleSkills` if both are set)
- Inside toolkit skill folders, file-level mirror cleanup still removes stale files

## Uninstall: `uninstall-toolkit.ps1`

Removes toolkit-deployed skills, rules, AGENTS.md, and sessions. Deletes only hook **scripts** shipped by this repo; rewrites `hooks.json` to drop toolkit entries and **keeps** user hook entries.

```powershell
.\scripts\uninstall-toolkit.ps1 -DryRun
.\scripts\uninstall-toolkit.ps1
```

Does **not** remove unrelated Cursor user settings.

## Validation suite (`validation/`)

```powershell
.\scripts\validation\validate-all.ps1
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

## Maintainer utilities (`maintainers/`)

| Script | Purpose |
|--------|---------|
| `maintainers/normalize-skill-encoding.ps1` | Fix mojibake in markdown |
| `maintainers/inject-skill-gates.ps1` | Add STOP blocks to skills missing them |
| `maintainers/fix-skill-gates.ps1` | Remove duplicate STOP blocks |
| `maintainers/migrate-manifest-v2.ps1` | Upgrade legacy SDD manifest |
| `maintainers/rename-skill-refs.ps1` | Bulk skill name migration |
| `maintainers/fix-encoding-and-skill-names.ps1` | Combined encoding + name fixes |
| `maintainers/fix-legacy-display-names.ps1` | Legacy display name migration |
| `maintainers/fix_mojibake.py` | Python mojibake helper |

## SDD setup (root)

| Script | Purpose |
|--------|---------|
| `configure-repo-sdd.ps1` | Register repo in manifest v2 (`classic` only) |

See `scripts/README.md` for the full layout (`validation/`, `maintainers/`, `_lib/`).

## Recommended workflow after changes

1. Edit skills/rules in repo
2. `.\scripts\sync-cursor.ps1`
3. `.\scripts\validation\validate-all.ps1`
4. Restart Cursor if hooks changed
