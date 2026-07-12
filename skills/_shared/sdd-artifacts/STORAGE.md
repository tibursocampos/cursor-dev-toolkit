# SDD artifact storage (sdd-spec / sdd-plan / sdd-develop)

Single source of truth for where Classic SDD and Forma C artifacts are written. Load on demand from skills - do not paste this file into PRD/PLAN bodies.

**Language:** This guideline file is **English**. Default **agent artifact** prose (FEATURE, STORY, PRD, PLAN, CONTINUITY) is **pt-BR** (`sdd-artifact-language-pt-br.mdc`). **Chat** replies and the storage prompt below are **pt-BR** unless the user overrides in the skill invocation.

Install path after sync: `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md`

## Storage modes

| Mode | Feature root | Spec Kit (unchanged) |
|------|--------------|----------------------|
| **repository** | `$Cwd/features/NNN-slug/` | `$Cwd/.specify/` |
| **global** | `<path>/features/NNN-slug/` where `<path>` = `~/.cursor/sdd/<repo-id>/` (or manifest `classic.path`) | `<path>/.specify/` |

Use `$HOME/.cursor/sdd/...` on macOS/Linux when expanding paths in tools.

**New writes (Classic Forma A / Forma B preferred / Forma C):** only under `features/NNN-slug/` (never loose `REFINE/`, `ANALYSIS/`, `ARCH/`, `SEC/`, `PRD/`, or `PLAN/` at repo root).

**No legacy root flow:** do **not** read, write, glob, or continue develop from repo-root / global-flat `PRD/` or `PLAN/`. Those patterns remain in `.gitignore` only as a safety net against accidental files.

## Feature tree schema

```text
features/NNN-slug/
├── FEATURE.md                 # Feature overview (Forma C / optional Forma A)
├── CONTINUITY.md              # Cross-agent / cross-session handoff
└── USnn/ or TSnn/             # Story folder (nn = 01, 02, …)
    ├── STORY.md               # Refined story + scorecard / deps
    ├── REFINE/                # Refine / breakdown scratch (optional)
    ├── ANALYSIS/              # Impact / risk notes (optional)
    ├── ARCH/                  # Architecture notes (optional)
    ├── SEC/                   # Security notes (optional)
    ├── PRD/                   # Canonical PRD for this story
    │   └── NNN_short_slug.md
    └── PLAN/
        └── PLAN_NNN_short_slug.md
```

| Segment | Rule |
|---------|------|
| `NNN` | Three digits; shared across feature folder and PRD/PLAN filenames |
| `slug` | kebab-case feature id |
| `USnn` / `TSnn` | User story or technical story; zero-padded index |
| Story subfolders | Create on demand; do not create the same names at **repo root** |

**Forma A (no O1 backlog):** create `features/NNN-slug/US01/` (default story) and write PRD/PLAN there unless the user names another `USnn`/`TSnn`.

**Templates (scaffold only):** `skills/_shared/templates/features/` in this toolkit repo.

## Repository mode - `.gitignore`

Run **before** the first `Write` under any SDD folder in the workspace (`sdd-spec` or `sdd-plan` in repository mode).

1. Read `.gitignore` at workspace root. If missing, create it with the SDD block below.
2. **Always** require these patterns in repository mode:

   | Pattern | When used |
   |---------|-----------|
   | `/features/` | Canonical Classic / Forma C artifacts (repo root only) |
   | `/docs/features/` | Reserved alternate under docs |
   | `/PRD/` | Safety net — ignore accidental root PRD (not a write destination) |
   | `/PLAN/` | Safety net — ignore accidental root PLAN (not a write destination) |
   | `/docs/PRD/` | Safety net |
   | `/docs/PLAN/` | Safety net |

   Use leading `/` so `skills/sdd-plan/`, `skills/_shared/templates/features/`, and other non-root paths are **not** ignored.

3. If **any** pattern is missing, append the **full** block:

   ```gitignore
   # SDD artifacts (local agent workflow - cursor-dev-toolkit)
   /features/
   /docs/features/
   /PRD/
   /PLAN/
   /docs/PRD/
   /docs/PLAN/
   ```

4. Report: patterns added, or all already present.

**Global mode:** do not modify project `.gitignore`.

## Numbering (`NNN`)

Collect existing sequence numbers from **features** locations before assigning `NNN`:

| Location | Glob |
|----------|------|
| Workspace features | `features/*/`, `docs/features/*/` (folder names `NNN-slug`) |
| Global features | `<classic.path>/features/*/` |

Use the highest `NNN` across all matches, then +1. PLAN `NNN` **must match** its feature folder and source PRD sequence.

Do **not** scan repo-root `PRD/` / `PLAN/` or global-flat `PRD/` / `PLAN/` for numbering.

## Filenames

| Artifact | Pattern | Typical path |
|----------|---------|--------------|
| Feature overview | `FEATURE.md` | `features/NNN-slug/FEATURE.md` |
| Continuity | `CONTINUITY.md` | `features/NNN-slug/CONTINUITY.md` |
| Story | `STORY.md` | `features/NNN-slug/USnn/STORY.md` |
| PRD | `NNN_short_feature_slug.md` | `features/NNN-slug/USnn/PRD/...` |
| PLAN | `PLAN_NNN_short_feature_slug.md` | `features/NNN-slug/USnn/PLAN/...` |

## Handoff paths

Always pass the **full path** used on disk:

```text
/sdd-plan - features/003-feature/US01/PRD/003_feature.md
/sdd-develop - features/003-feature/US01/PLAN/PLAN_003_feature.md - Step 1
/speckit-plan - .specify/specs/003-feature/spec.md
/speckit-develop - .specify/specs/003-feature/tasks.md
```

## Forbidden paths (not used)

Do **not** read, write, or continue Classic SDD from:

| Path | Reason |
|------|--------|
| `$Cwd/PRD/`, `$Cwd/PLAN/` | Not part of the active flow (gitignore safety net only) |
| `$Cwd/docs/PRD/`, `$Cwd/docs/PLAN/` | Same |
| `<global>/PRD/`, `<global>/PLAN/` (flat, outside `features/`) | Same |
| Loose `REFINE/` / `ANALYSIS/` / `ARCH/` / `SEC/` at repo root | Must live under `features/NNN-slug/USnn/` |
| `docs/backlog/` | Forma B shortcut drafts only — not canonical PRD/PLAN |
| Generic `docs/*.md`, repo-root markdown without feature tree | Not SDD storage |

When the user cites a non-canonical `.md`: read it, build the artifact per skill templates, confirm path (`PIPELINE.md` § Confirm before write), then `Write` only under `features/NNN-slug/...`.

## Skill responsibilities

| Skill | Storage question | `.gitignore` | Writes |
|-------|------------------|--------------|--------|
| sdd-spec | Yes (confirm path) | Repository mode only | PRD under `features/.../PRD/` |
| sdd-plan | Yes if manifest missing | Repository mode only | PLAN under `features/.../PLAN/` |
| sdd-develop | No - uses PLAN path from input | No | Updates same PLAN file |
| orchestrate-* (Forma C) | Yes if first run | Repository mode only | Feature tree + stories |
| refine-backlog-item | Prefer feature `STORY.md` | No (unless first SDD write) | Optional `docs/backlog/` shortcut |
| breakdown-tasks | Prefer feature story folder | No | Task checklist under story / backlog |
| speckit-setup | No | No | Global manifest directories |
| speckit-init | Yes (resolves storage) | Repository mode only | `.specify/` + manifest |
| speckit-spec | No - uses resolved storage | Repository mode only | `spec.md` |
| speckit-plan | No - uses resolved storage | Repository mode only | `plan.md` + `tasks.md` |
| speckit-develop | No - uses resolved storage | No | Updates `tasks.md` |
| code-review | No | No | Read-only |
| fix-build | No | No | Read-only |
| document-plan / document-implement | No | No | **Do not** use this file for `docs/documentation-plan/plan.md` |

---

## Global manifest and dynamic storage resolution (schema v2)

> **Used by:** all `sdd-*`, `speckit-*`, `refine-backlog-item`, `breakdown-tasks`, and Forma C `orchestrate-*` skills.

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

Run `.\scripts\maintainers\migrate-manifest-v2.ps1` to persist. Write back on first skill run after migration.

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
6. Derive classic feature root:
   - repository -> $Cwd/features/
   - global     -> <classic.path>/features/
7. For classic writes and reads: resolve only under
   features/NNN-slug/[USnn|TSnn]/{PRD|PLAN|...}
   (Forma A default story = US01 when unspecified).
   Never use repo-root or global-flat PRD/ / PLAN/.
8. For speckit skills (except setup/init): if speckit.initialized != true, run
   `validation/validate-speckit-init.ps1`; if fail -> STOP - handoff to speckit-init.
```

### Physical path mapping

| storage_mode | Spec Kit | Classic feature root | Classic PRD | Classic PLAN |
|---|---|---|---|---|
| `repository` | `$Cwd/.specify/` | `$Cwd/features/` | `$Cwd/features/NNN-slug/USnn/PRD/` | `$Cwd/features/NNN-slug/USnn/PLAN/` |
| `global` | `<path>/.specify/` | `<path>/features/` | `<path>/features/NNN-slug/USnn/PRD/` | `<path>/features/NNN-slug/USnn/PLAN/` |

`<path>` = `repositories[$Cwd][$Workflow].path`

### Resolution checklist (repository vs global)

| Check | repository | global |
|-------|------------|--------|
| Feature root | `$Cwd/features/NNN-slug/` | `~/.cursor/sdd/<repo-id>/features/NNN-slug/` (or manifest path) |
| PRD/PLAN | Under story `PRD/` / `PLAN/` only | Same under global feature root |
| `.gitignore` SDD block | Required (incl. `/features/` + safety-net `/PRD/` `/PLAN/`) | Do not edit project `.gitignore` |
| Root / flat `PRD/`/`PLAN/` | Not used (ignored if present) | Not used |
| Leading `/` on ignore patterns | Must not ignore `skills/sdd-plan/` | N/A |

### User storage prompt (chat only - pt-BR)

Ask before the first write of Classic artifacts in the session (unless manifest applies):

```text
Onde gravar artefatos SDD (features/) deste projeto?

1) Repositório - features/ na raiz (/features/, /docs/features/, e safety-net /PRD/, /PLAN/ no .gitignore se faltarem)
2) Global - ~/.cursor/sdd/<RepositoryName>/features/ (fora do git do projeto)
```

## Integration

- Pipeline guards: `_shared/sdd-artifacts/PIPELINE.md`
- Session gates: `_shared/sdd-artifacts/SESSION.md`
- Feature templates: `_shared/templates/features/`
- Always-on rules: `rules/sdd-pipeline-guards.mdc`, `rules/guardrails.mdc`
