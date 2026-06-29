# Core architecture - cursor-dev-toolkit

## Deployment layer

The toolkit deploys to the user Cursor profile:

| Source | Target |
|--------|--------|
| `AGENTS.md` | `~/.cursor/AGENTS.md` |
| `skills/` | `~/.cursor/skills/` |
| `rules/*.md` | `~/.cursor/rules/*.mdc` |
| `hooks/` | `~/.cursor/hooks/` + merged `hooks.json` |
| SDD sessions | `~/.cursor/sdd/sessions/` (created on sync) |

Orchestration: `scripts/sync-cursor.ps1` (idempotent SHA-256 mirror deploy) or `scripts/toolkit.ps1` (interactive menu).

## Enforcement layers

Cursor supports native always-on rules and optional hooks:

1. **`guardrails.mdc`** and eight companion rules (including `ai-stealth.mdc`)
2. **`SESSION.md` + session-state** gates in `~/.cursor/sdd/sessions/{repo-hash}.json`
3. **Gate-first Step -1** blocks in every skill
4. **Optional hooks** - skill tracking, PLAN edit state, context warnings
5. **`validate-all.ps1`** smoke test after sync

Unlike Antigravity, this toolkit does **not** use Knowledge Items (KI). Rules with `alwaysApply: true` replace KI injection.

## Storage architecture (manifest v2)

Resolved by `~/.cursor/sdd/manifest.json`:

- `classic` for `sdd-*` skills
- `speckit` for `speckit-*` skills

Each section supports `storage_mode: repository | global` and `path`.

## Session-state gates

Per-repo file: `~/.cursor/sdd/sessions/{repo-hash}.json`

| Gate | Purpose |
|------|---------|
| `storage_confirmed` | Manifest/storage path changes |
| `write_confirmed` | New SDD artifacts |
| `step_confirmed` | Before implement |
| `tests_run` | Before marking step done |

## Developer skill model

| Skill | Role |
|-------|------|
| `developer` | Router: detects stack and delegates |
| `dotnet-developer` | .NET implementation |
| `react-developer` | React implementation |
| `angular-developer` | Angular implementation |
| `javascript-developer` | Node/JS implementation |
| `python-developer` | Python implementation |

Persona/routing policy lives in `rules/` + `AGENTS.md` (no `dev_persona` skill).

## Validation pipeline

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validation\validate-all.ps1
```

| Script | Purpose |
|--------|---------|
| `validate-toolkit-deploy.ps1` | 9 rules, hooks paths, AGENTS.md |
| `validate-skills-structure.ps1` | STOP gates, line limits, manifest v2 |
| `validate-docs-consistency.ps1` | Catalog vs folders, obsolete names |
| `validate-skills-english.ps1` | Skill body language heuristic |

See [guides/09-scripts-and-toolkit.md](guides/09-scripts-and-toolkit.md).
