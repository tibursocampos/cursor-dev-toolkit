# Scripts layout

| Location | Purpose |
|----------|---------|
| **Root** | Deploy, SDD setup, orchestration |
| `validation/` | Smoke test suite (`validate-all.ps1` and checks) |
| `inventory/` | Read-only memory-bank inventory (`Invoke-MemoryBankInventory.ps1`) |
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
| `sync-cursor.ps1` | Deploy to `~/.cursor/` (default keeps extra skills; `-PruneStaleSkills` to mirror-prune) |
| `configure-repo-sdd.ps1` | Register repo in manifest v2 |
| `uninstall-toolkit.ps1` | Remove toolkit skills/rules; surgical hooks.json edit (keeps user hooks) |
| `toolkit.ps1` | Interactive menu |

## Inventory (memory-bank)

Read-only scan of a **consumer** repo; writes only under `memory-bank/.inventory/`:

```powershell
.\scripts\inventory\Invoke-MemoryBankInventory.ps1 -RepoPath "D:\Source\Repos\MyApp" -AllowCreateInventory
.\scripts\inventory\Invoke-MemoryBankInventory.ps1 -RepoPath "D:\Source\Repos\MyApp" -DryRun
```

Used by `/memory-bank-init`. Prefer gitignoring `memory-bank/.inventory/` in the consumer; version stable markdown/json in the bank.

## Validation

Run from repo root:

```powershell
.\scripts\validation\validate-all.ps1
.\scripts\validation\validate-all.ps1 -IncludeSessionGate -RepoPath "D:\Source\Repos\MyApp"
```

Core checks include: deploy, skills-structure, impeccable-skill, blip-plugin-skill, frontend-ecosystem, docs-consistency, skills-english.

## Maintainers

Run only when fixing toolkit content (not required after normal sync):

```powershell
.\scripts\maintainers\normalize-skill-encoding.ps1
.\scripts\maintainers\migrate-manifest-v2.ps1 -DryRun
```
