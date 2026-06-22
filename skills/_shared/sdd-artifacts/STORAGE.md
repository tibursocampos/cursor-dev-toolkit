# SDD artifact storage (sdd-spec / sdd-plan / sdd-develop)

Single source of truth for where PRD and PLAN files are written. Load on demand from skills - do not paste this file into PRD/PLAN bodies.

**Language:** This guideline file is **English**. Default **PRD/PLAN artifact** prose is **pt-BR** (`sdd-artifact-language-pt-br.mdc`). **Chat** replies and the storage prompt below are **pt-BR** unless the user overrides in the skill invocation.

Install path after sync: `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md`

## Storage modes

| Mode | PRD folder | PLAN folder |
|------|------------|-------------|
| **repository** | `PRD/` (preferred) or `docs/PRD/` | `PLAN/` at workspace root |
| **global** | `<path>/PRD/` under resolved manifest path | `<path>/PLAN/` |

Use `$HOME/.cursor/sdd/...` on macOS/Linux when expanding paths in tools.

## Repository mode - `.gitignore`

Run **before** the first `Write` under any SDD folder in the workspace (`sdd-spec` or `sdd-plan` in repository mode).

1. Read `.gitignore` at workspace root. If missing, create it with the SDD block below.
2. **Always** require these four patterns in repository mode:

   | Pattern | When used |
   |---------|-----------|
   | `/PRD/` | Default PRD location (repo root only) |
   | `/PLAN/` | Default PLAN location (repo root only) |
   | `/docs/PRD/` | Alternate PRD location |
   | `/docs/PLAN/` | Reserved alternate |

   Use leading `/` so `skills/sdd-plan/` and other paths named `plan` are not ignored.

3. If **any** of the four is missing, append the **full** block:

   ```gitignore
   # SDD artifacts (local agent workflow - cursor-dev-toolkit)
   /PRD/
   /PLAN/
   /docs/PRD/
   /docs/PLAN/
   ```

4. Report: patterns added, or all four already present.

**Global mode:** do not modify project `.gitignore`.

## PRD / PLAN numbering

Collect existing files from workspace and global paths before assigning `NNN`:

| Location | Glob |
|----------|------|
| Workspace | `PRD/*.md`, `docs/PRD/*.md`, `PLAN/PLAN_*.md` |
| Global | `<classic.path>/PRD/*.md`, `<classic.path>/PLAN/PLAN_*.md` |

Use the highest `NNN` across all matches, then +1. PLAN `NNN` must match the source PRD sequence.

## Filenames

| Artifact | Pattern |
|----------|---------|
| PRD | `NNN_short_feature_slug.md` |
| PLAN | `PLAN_NNN_short_feature_slug.md` |

## Handoff paths

Always pass the **full path** used on disk:

```text
use skill sdd-plan - PRD/003_feature.md
use skill sdd-develop - PLAN/PLAN_003_feature.md - Step 1
use skill speckit-plan - .specify/specs/003-feature/spec.md
use skill speckit-develop - .specify/specs/003-feature/tasks.md
```

## Invalid paths and promotion

**Forbidden** as final SDD destinations: `docs/backlog/`, generic `docs/*.md`, repo-root markdown without `NNN_` / `PLAN_NNN_` patterns.

When the user cites a non-canonical `.md`: read it, build the artifact per skill templates, confirm path (`PIPELINE.md` § Confirm before write), then `Write` only under canonical locations.

## Skill responsibilities

| Skill | Storage question | `.gitignore` | Writes |
|-------|------------------|--------------|--------|
| sdd-spec | Yes (confirm path) | Repository mode only | PRD |
| sdd-plan | Yes if manifest missing | Repository mode only | PLAN |
| sdd-develop | No - uses PLAN path from input | No | Updates same PLAN file |
| speckit-setup | No | No | Global manifest directories |
| speckit-init | Yes (resolves storage) | Repository mode only | `.specify/` + manifest |
| speckit-spec | No - uses resolved storage | Repository mode only | `spec.md` |
| speckit-plan | No - uses resolved storage | Repository mode only | `plan.md` + `tasks.md` |
| speckit-develop | No - uses resolved storage | No | Updates `tasks.md` |
| code-review | No | No | Read-only |
| refine-backlog-item | No | No | Read-only when listing PRDs |
| breakdown-tasks | No | No | Read-only when resolving PLAN |
| fix-build | No | No | Read-only |
| document-plan / document-implement | No | No | **Do not** use this file for `docs/documentation-plan/plan.md` |

---

## Global manifest and dynamic storage resolution (schema v2)

> **Used by:** all `sdd-*`, `speckit-*`, `refine-backlog-item`, `breakdown-tasks` skills.

### Manifest location

```
$env:USERPROFILE\.cursor\sdd\manifest.json
```

### Manifest structure (v2)

```json
{
  "schema_version": 2,
  "repositories": {
    "D:/Source/Repos/MyApp": {
      "classic": {
        "storage_mode": "global",
        "path": "$HOME/.cursor/sdd/MyApp"
      },
      "speckit": {
        "storage_mode": "global",
        "path": "$HOME/.cursor/sdd/MyApp",
        "initialized": true,
        "init_validated_at": "2026-06-21T12:00:00Z"
      }
    }
  }
}
```

Use placeholder paths in docs; never hardcode `C:/Users/<name>/...`.

### Legacy migration (v1 -> v2)

If a repository entry has top-level `storage_mode` and `path` (no `classic`/`speckit`), migrate in memory:

```json
{
  "classic": { "storage_mode": "repository", "path": "D:/Source/Repos/MyApp" },
  "speckit": { "storage_mode": "repository", "path": "D:/Source/Repos/MyApp", "initialized": false }
}
```

Run `.\scripts\migrate-manifest-v2.ps1` to persist. Write back on first skill run after migration.

### Resolution algorithm

Execute at skill load time, before any read or write. Parameter: `$Workflow` = `classic` | `speckit`.

```
1. Normalize $Cwd (replace \ with /, trim trailing /).
2. Read manifest.json; ensure schema_version = 2 (migrate v1 if needed).
3. Look up repositories[$Cwd].
4. If NOT found (first run):
   a. Ask user (pt-BR) storage for classic SDD (local vs global).
   b. Ask user (pt-BR) storage for Spec Kit (local vs global - may match classic path).
   c. Write classic + speckit sections; set speckit.initialized = false.
   d. Set session gate storage_confirmed = true after user sim.
5. If found: read repositories[$Cwd][$Workflow].storage_mode and .path.
6. For speckit skills (except setup/init): if speckit.initialized != true, run validate-speckit-init.ps1;
   if fail -> STOP - handoff to speckit-init.
```

### Physical path mapping

| storage_mode | Spec Kit | Classic PRD | Classic PLAN |
|---|---|---|---|
| `repository` | `$Cwd/.specify/` | `$Cwd/PRD/` or `$Cwd/docs/PRD/` | `$Cwd/PLAN/` |
| `global` | `<path>/.specify/` | `<path>/PRD/` | `<path>/PLAN/` |

`<path>` = `repositories[$Cwd][$Workflow].path`

### User storage prompt (chat only - pt-BR)

Ask before the first write of PRD or PLAN in the session (unless manifest applies):

```text
Onde gravar PRD/PLAN deste projeto?

1) Repositório - PRD/ e PLAN/ na raiz (e pastas docs/PRD/, docs/PLAN/ sempre no .gitignore se faltarem)
2) Global - ~/.cursor/sdd/<RepositoryName>/ (fora do git do projeto)
```

## Integration

- Pipeline guards: `_shared/sdd-artifacts/PIPELINE.md`
- Session gates: `_shared/sdd-artifacts/SESSION.md`
- Always-on rules: `rules/sdd-pipeline-guards.mdc`, `rules/guardrails.mdc`
