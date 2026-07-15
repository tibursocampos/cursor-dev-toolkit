# Cross-toolkit sync policy

How **cursor-dev-toolkit** and **antigravity-dev-toolkit** stay aligned.

## Canonical direction

| Content type | Source of truth | Port to |
|--------------|-------------------|---------|
| Stack skills, `_shared` guidelines (git, frontend, devops, dotnet extras) | antigravity -> cursor | `sync-cursor.ps1` paths |
| Rules granularity, hooks, `developer-common`, `format-validators` | cursor -> antigravity | `sync-antigravity.ps1` + KI/GUARDRAILS |
| Operational skills (`ef-add-migration`, `scaffold-message-handler`) | cursor -> antigravity | snake_case folders |
| Impeccable `reference/*.md` + router | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) -> cursor | `skills/impeccable/` via `sync-impeccable-refs.ps1` - **not** from antigravity personas |
| Frontend stack skills (`vue-developer`, `blazor-developer`, `electron-developer`) | cursor (authored) | Optional port to antigravity later - not required for Cursor deploy |
| Blip plugin skill + `blip-guidelines/` | cursor (authored) | Optional port to antigravity (`blip_plugin_developer`) - manual, not in `sync-cursor.ps1` |
| `dev_persona` | antigravity only | **Not ported** - Cursor uses `rules/` + `AGENTS.md` |
| Documentation architecture | Each repo adapts to its IDE model | See `docs/architecture.md` (Cursor) / `docs/core-architecture.md` (Antigravity) |

## Naming

- **Cursor:** kebab-case folders (`dotnet-developer`).
- **Antigravity:** snake_case folders (`dotnet_developer`).
- Do not normalize names across repos during port; adapt paths only.

## Validation after port

**Cursor:**

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validation\validate-all.ps1
```

**Antigravity:**

```powershell
.\scripts\sync-antigravity.ps1
.\scripts\validation\validate-all.ps1
```

## CI

Both repos run `validate-all.ps1` on pull requests via `.github/workflows/validate-toolkit.yml`.
