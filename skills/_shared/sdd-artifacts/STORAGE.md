# SDD artifact storage (spec / plan / implement)

Single source of truth for where PRD and PLAN files are written. Load on demand from skills — do not paste this file into PRD/PLAN bodies.

Install path after sync: `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md`

## Storage modes

| Mode | PRD folder | PLAN folder |
|------|------------|-------------|
| **repository** | `PRD/` (preferred) or `docs/PRD/` | `PLAN/` at workspace root |
| **global** | `~/.cursor/sdd/<repo-id>/PRD/` | `~/.cursor/sdd/<repo-id>/PLAN/` |

Use `$HOME/.cursor/sdd/...` on macOS/Linux when expanding paths in tools.

## Resolve `<repo-id>`

Apply in order; use the first stable result:

1. `git remote get-url origin` → slug: take last path segment without `.git`, map to `owner-repo` (lowercase; non-alphanumeric → `-`; collapse repeated `-`).
2. Else: basename of workspace root directory.
3. Persist in manifest (below) so later sessions reuse the same id.

Example: `https://github.com/acme/payments-api.git` → `acme-payments-api`.

## Manifest

Path: `~/.cursor/sdd/<repo-id>/manifest.json`

Write on the **first** SDD write in a workflow (spec or plan) after the user chooses storage (or when inferring from an existing global PRD path).

```json
{
  "repo_id": "acme-payments-api",
  "workspace_root": "D:/Source/Repos/payments-api",
  "storage": "repository",
  "artifact_language": "pt-BR",
  "prd_folder": "PRD",
  "plan_folder": "PLAN"
}
```

| Field | Values |
|-------|--------|
| `storage` | `repository` \| `global` |
| `artifact_language` | `pt-BR` (default) \| `en` (only when user overrides in skill invocation) |
| `prd_folder` | `PRD`, `docs/PRD`, or absolute global PRD directory |
| `plan_folder` | `PLAN` or absolute global PLAN directory |

**Read manifest before asking storage** when:

- File exists, JSON is valid, and `workspace_root` matches the open workspace root (normalize path separators).

**Ask storage again** when manifest is missing, invalid, or `workspace_root` does not match.

**Infer global without asking** when the user passes a PRD or PLAN path under `~/.cursor/sdd/` (or `%USERPROFILE%\.cursor\sdd\`).

## User prompt (pt-BR in chat)

Ask before the first write of PRD or PLAN in the session (unless manifest applies):

```
Onde gravar PRD/PLAN deste projeto?

1) Repositório — PRD/ e PLAN/ na raiz do projeto (entradas adicionadas ao .gitignore se faltarem)
2) Global — ~/.cursor/sdd/<repo-id>/ (fora do git do projeto)
```

Show the resolved `<repo-id>` in option 2.

## Repository mode — `.gitignore`

Run **before** creating or writing under `PRD/`, `docs/PRD/`, or `PLAN/` in the workspace.

1. Read `.gitignore` at workspace root. If missing, create it with only the SDD block below (tell the user).
2. Treat a pattern as present if `.gitignore` contains a line that ignores the path (exact line or equivalent):
   - `PRD/` — always required for repository mode
   - `PLAN/` — always required
   - `docs/PRD/` — only when `prd_folder` is `docs/PRD`
3. If any required pattern is missing, append:

   ```
   # SDD artifacts (local agent workflow — cursor-dev-toolkit)
   PRD/
   PLAN/
   ```

   Add `docs/PRD/` on its own line when using that folder.

4. Report: patterns added, or all already ignored. Do not duplicate existing entries.

**Global mode:** do not modify project `.gitignore`.

## PRD / PLAN numbering

Collect existing files from **both** locations before assigning `NNN`:

| Location | Glob |
|----------|------|
| Workspace | `PRD/*.md`, `docs/PRD/*.md`, `PLAN/PLAN_*.md` |
| Global | `~/.cursor/sdd/<repo-id>/PRD/*.md`, `.../PLAN/PLAN_*.md` |

Use the highest `NNN` across all + 1. PLAN `NNN` must match the source PRD sequence.

## Filenames

| Artifact | Pattern |
|----------|---------|
| PRD | `NNN_short_feature_slug.md` (3-digit `NNN`, ASCII slug; Portuguese words allowed) |
| PLAN | `PLAN_NNN_short_feature_slug.md` |

## Handoff paths

Always pass the **full path** used on disk (relative to workspace or absolute for global):

```
use skill plan — PRD/003_feature.md
use skill plan — ~/.cursor/sdd/acme-payments-api/PRD/003_feature.md

use skill implement — PLAN/PLAN_003_feature.md — Step 1
use skill implement — ~/.cursor/sdd/acme-payments-api/PLAN/PLAN_003_feature.md — Step 1
```

## Skill responsibilities

| Skill | Storage question | `.gitignore` | Writes |
|-------|------------------|--------------|--------|
| spec | Yes (or manifest) | Repository mode only | PRD + manifest |
| plan | Yes if manifest missing; infer if PRD is global | Repository mode only | PLAN + manifest |
| implement | No — use PLAN path from input | No | Updates same PLAN file |
| code-review | No | No | Read-only: manifest + glob repo/global; no writes |

## Integration

- Templates: `skills/spec/reference.md`, `skills/plan/reference.md`
- SDD discovery (read-only): `skills/code-review/reference.md` § SDD artifact resolution
- Context rule: `rules/context-management.md`
- Hooks: `hooks/_hook-common.ps1` (`Test-PlanFilePath` includes global PLAN paths)
