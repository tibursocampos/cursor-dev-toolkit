# Scripts layout

| Location | Purpose |
|----------|---------|
| **Root** | Deploy, SDD setup, orchestration |
| `validation/` | Smoke test suite (`validate-all.ps1` and checks) |
| `maintainers/` | One-off fixes, migrations, encoding, gate injection |
| `_lib/` | Shared helpers (`Get-ToolkitRepoRoot`) |

## Root (daily use)

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validation\validate-all.ps1
.\scripts\toolkit.ps1
```

| Script | Role |
|--------|------|
| `sync-cursor.ps1` | Deploy to `~/.cursor/` |
| `setup-speckit.ps1` | Spec Kit CLI prerequisites |
| `configure-repo-sdd.ps1` | Register repo in manifest v2 |
| `uninstall-toolkit.ps1` | Remove toolkit from `~/.cursor/` |
| `toolkit.ps1` | Interactive menu |

## Validation

Run from repo root:

```powershell
.\scripts\validation\validate-all.ps1
.\scripts\validation\validate-all.ps1 -IncludeSpeckit -RepoPath "D:\Source\Repos\MyApp"
```

Core checks include: deploy, skills-structure, impeccable-skill, blip-plugin-skill, frontend-ecosystem, docs-consistency, skills-english.

## Maintainers

Run only when fixing toolkit content (not required after normal sync):

```powershell
.\scripts\maintainers\normalize-skill-encoding.ps1
.\scripts\maintainers\migrate-manifest-v2.ps1 -DryRun
```
