# Session state and gates

Load at **step -1** of every skill. Do not paste into PRD/PLAN/sdd-spec bodies.

Install path after sync: `~/.cursor/skills/_shared/sdd-artifacts/SESSION.md`

## Session file location

```
$env:USERPROFILE\.cursor\sdd\sessions\{repo-hash}.json
```

`{repo-hash}` = first 16 hex chars of SHA256 of normalized `$Cwd` (forward slashes, no trailing slash).

## Session schema

```json
{
  "repo": "D:/Source/Repos/MyApp",
  "workflow": "classic|speckit|none",
  "phase": "spec|plan|develop|idle",
  "gates": {
    "storage_confirmed": false,
    "write_confirmed": false,
    "step_confirmed": false,
    "tests_run": false
  },
  "current_step": null,
  "updated_at": "2026-06-21T12:00:00Z"
}
```

## Resolution algorithm

```
1. Normalize $Cwd (replace \ with /, trim trailing /).
2. Compute repo-hash = SHA256(normalized path)[0:16].
3. sessionsDir = $env:USERPROFILE\.cursor\sdd\sessions
   - Create sessionsDir if missing.
4. sessionPath = sessionsDir\{repo-hash}.json
5. If file missing: create default schema with repo = $Cwd, workflow = none, phase = idle.
6. Read session; use gates before Write/Shell.
```

## Gate rules

| Gate | Set `true` when | Required for |
|------|-----------------|--------------|
| `storage_confirmed` | User chose local/global storage (first SDD run) | First PRD/sdd-spec write |
| `write_confirmed` | User said **sim** to confirm-before-write | New PRD/PLAN/sdd-spec/sdd-plan/tasks |
| `step_confirmed` | User said **sim** to implement current step/task | `sdd-develop`, `speckit-develop`, `document-implement` |
| `tests_run` | Tests executed and reported | Before marking step/task done |

## Before Write or mutating Shell

1. Read session file for `$Cwd`.
2. If required gate is `false`: **STOP** - ask user **(pt-BR)** - do not proceed.
3. After user **sim**: set gate `true`, update `updated_at`, write session file.

## After develop step completes (mandatory)

1. Set `write_confirmed`, `step_confirmed`, `tests_run` to `false`.
2. Set `phase` to `idle` or keep `develop` with `current_step` updated.
3. Write session file.
4. **STOP** session - handoff to new conversation.

## Validation script

```powershell
.\scripts\validate-session-gates.ps1 -RepoPath "D:\Source\Repos\MyApp" -RequiredGate write_confirmed
```

Exit 0 = gate approved; exit 1 = blocked.

## Integration

| Consumer | Use |
|----------|-----|
| All skills | Step -1 gate check before Write/Shell |
| `rules/guardrails.mdc` | References this file |
| `rules/context-management.mdc` | Complements session gates |
