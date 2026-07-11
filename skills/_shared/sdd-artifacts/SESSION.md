# Session state and gates

Load at **step -1** of every skill. Do not paste into PRD/PLAN/sdd-spec bodies.

Install path after sync: `~/.cursor/skills/_shared/sdd-artifacts/SESSION.md`

## Session file locations

Two scopes share the same directory root:

```
$env:USERPROFILE\.cursor\sdd\sessions\
```

| Scope | Path | Gates owned |
|-------|------|-------------|
| **Repo** | `{repo-hash}.json` | `storage_confirmed`, `write_confirmed` (+ workflow / phase summary) |
| **Develop (PLAN)** | `{repo-hash}/plan-{plan-hash}.json` | `step_confirmed`, `tests_run` |
| **Develop (PLAN+step)** | `{repo-hash}/plan-{plan-hash}-step-{N}.json` | `step_confirmed`, `tests_run` (parallel same PLAN) |

`{repo-hash}` = first 16 hex chars of SHA256 of normalized `$Cwd` (forward slashes, no trailing slash).

`{plan-hash}` = first 16 hex chars of SHA256 of normalized **full PLAN path** (or Spec Kit `tasks.md` path) — forward slashes, no trailing slash.

Use **PLAN+step** files when `orchestrate-develop` spawns parallel children on the **same** PLAN (steps marked parallel-safe). Default Forma A / O3 série: one `plan-{plan-hash}.json` per PLAN.

## Repo session schema

```json
{
  "repo": "D:/Source/Repos/MyApp",
  "workflow": "classic|speckit|none",
  "phase": "spec|plan|develop|idle",
  "gates": {
    "storage_confirmed": false,
    "write_confirmed": false
  },
  "current_step": null,
  "updated_at": "2026-06-21T12:00:00Z"
}
```

Legacy repo files may still contain `step_confirmed` / `tests_run`. On first develop load with a PLAN path, **migrate** those two gates into the scoped develop file (read legacy, write scoped, then clear develop gates on the repo file or leave them unused). Do not delete the legacy file without reading it.

## Develop session schema

```json
{
  "repo": "D:/Source/Repos/MyApp",
  "plan_path": "D:/Source/Repos/MyApp/features/004-x/US01/PLAN/PLAN_004_x.md",
  "step": null,
  "workflow": "classic|speckit|none",
  "phase": "develop|idle",
  "gates": {
    "step_confirmed": false,
    "tests_run": false
  },
  "current_step": null,
  "updated_at": "2026-06-21T12:00:00Z"
}
```

`step` is an integer when using PLAN+step scoping; otherwise `null`.

## Resolution algorithm

### Repo session

```
1. Normalize $Cwd (replace \ with /, trim trailing /).
2. repo-hash = SHA256(normalized path)[0:16].
3. sessionsDir = $env:USERPROFILE\.cursor\sdd\sessions
   - Create sessionsDir if missing.
4. sessionPath = sessionsDir\{repo-hash}.json
5. If file missing: create default repo schema with repo = $Cwd, workflow = none, phase = idle.
6. Read session; use storage_confirmed / write_confirmed before Write/Shell that needs them.
```

### Develop session (sdd-develop / speckit-develop / O3 child)

```
1. Resolve full PLAN path (or tasks.md path). Normalize (\ -> /, trim trailing /).
2. plan-hash = SHA256(normalized PLAN path)[0:16].
3. repo-hash as above from $Cwd.
4. Ensure sessionsDir\{repo-hash}\ exists.
5. If parallel same-PLAN step N:
     sessionPath = sessionsDir\{repo-hash}\plan-{plan-hash}-step-{N}.json
   Else:
     sessionPath = sessionsDir\{repo-hash}\plan-{plan-hash}.json
6. If scoped file missing:
   a. If legacy sessionsDir\{repo-hash}.json has step_confirmed/tests_run, copy them into a new scoped file (migration).
   b. Else create default develop schema (gates false).
7. Read scoped session for step_confirmed / tests_run.
8. Always read repo session separately for storage_confirmed / write_confirmed when those gates apply.
```

## Gate rules

| Gate | File | Set `true` when | Required for |
|------|------|-----------------|--------------|
| `storage_confirmed` | Repo | User chose local/global storage (first SDD run) | First PRD/sdd-spec write |
| `write_confirmed` | Repo | User said **sim** to confirm-before-write | New PRD/PLAN/sdd-spec/sdd-plan/tasks |
| `step_confirmed` | Develop (PLAN or PLAN+step) | User said **sim** to implement current step/task | `sdd-develop`, `speckit-develop`, `document-implement` |
| `tests_run` | Develop (PLAN or PLAN+step) | Tests executed and reported | Before marking step/task done |

## Before Write or mutating Shell

1. Resolve the correct session file(s) for the gate in play.
2. If required gate is `false`: **STOP** - ask user **(pt-BR)** - do not proceed.
3. After user **sim**: set gate `true`, update `updated_at`, write **that** session file only.

## After develop step completes (mandatory)

1. On the **scoped develop** file: set `step_confirmed` and `tests_run` to `false`; set `phase` to `idle` or keep `develop` with `current_step` updated.
2. On the **repo** file: set `write_confirmed` to `false` if it was used; do **not** clear another PLAN's develop gates.
3. Write only the files touched.
4. **STOP** that develop scope - handoff to new conversation (or next O3 child with its own scoped file).

## Parallel O3 (Forma C)

Parallel `sdd-develop` children **must** use distinct develop session files:

| Parallel case | Session file |
|---------------|--------------|
| Different PLANs | `plan-{planHashA}.json` and `plan-{planHashB}.json` |
| Same PLAN, parallel-safe steps | `plan-{planHash}-step-{N}.json` per step |

Also require disjoint file scopes in the working tree (see `orchestrate-develop`). No git worktrees in MVP.

## Validation script

```powershell
.\scripts\validation\validate-session-gates.ps1 -RepoPath "D:\Source\Repos\MyApp" -RequiredGate write_confirmed
.\scripts\validation\validate-session-gates.ps1 -RepoPath "D:\Source\Repos\MyApp" -PlanPath "D:\...\PLAN_004_x.md" -RequiredGate step_confirmed
.\scripts\validation\validate-session-gates.ps1 -RepoPath "D:\Source\Repos\MyApp" -PlanPath "D:\...\PLAN_004_x.md" -Step 2 -RequiredGate tests_run
```

Exit 0 = gate approved; exit 1 = blocked.

## Integration

| Consumer | Use |
|----------|-----|
| All skills | Step -1 gate check before Write/Shell |
| `sdd-develop` / `speckit-develop` / O3 children | Develop session scoped by PLAN (or PLAN+step) |
| `rules/guardrails.mdc` | References this file |
| `rules/context-management.mdc` | Complements session gates |
