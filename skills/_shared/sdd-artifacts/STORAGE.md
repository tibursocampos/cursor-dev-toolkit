# SDD artifact storage (spec / plan / implement)

Single source of truth for where PRD and PLAN files are written. Load on demand from skills — do not paste this file into PRD/PLAN bodies.

**Language:** This guideline file is **English**. Default **PRD/PLAN artifact** prose is **pt-BR** (`artifact_language`, `sdd-artifact-language-pt-br.mdc`). **Chat** replies and the storage prompt below are **pt-BR** unless the user overrides in the skill invocation.

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

Write on the **first** SDD write in a workflow (`spec` or `plan`) after the user chooses storage (or when inferring from an existing global PRD path).

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
| `prd_folder` | `PRD`, `docs/PRD`, or absolute path under `~/.cursor/sdd/<repo-id>/PRD/` only |
| `plan_folder` | `PLAN` or absolute path under `~/.cursor/sdd/<repo-id>/PLAN/` only |

Manifest folders must match **canonical** layouts in `PIPELINE.md` § Canonical paths — not arbitrary directories.

**Read manifest before asking storage** when:

- File exists, JSON is valid, and `workspace_root` matches the open workspace root (normalize path separators).

**Ask storage again** when manifest is missing, invalid, or `workspace_root` does not match.

**Infer global without asking** when the user passes a PRD or PLAN path under `~/.cursor/sdd/` (or `%USERPROFILE%\.cursor\sdd\`).

## User storage prompt (chat only — pt-BR)

Ask before the first write of PRD or PLAN in the session (unless manifest applies). Copy **verbatim** to the user in **pt-BR** (not English):

```text
Onde gravar PRD/PLAN deste projeto?

1) Repositório — PRD/ e PLAN/ na raiz (e pastas docs/PRD/, docs/PLAN/ sempre no .gitignore se faltarem)
2) Global — ~/.cursor/sdd/<repo-id>/ (fora do git do projeto)
```

Show the resolved `<repo-id>` in option 2.

## Repository mode — `.gitignore`

Run **before** the first `Write` under any SDD folder in the workspace (`spec` or `plan` in repository mode). Applies to **every** consumer repository, including the first time those directories are created.

1. Read `.gitignore` at workspace root. If missing, create it with the SDD block below (tell the user).
2. **Always** require these four patterns in repository mode (even if only one folder will receive files now):

   | Pattern | When used |
   |---------|-----------|
   | `/PRD/` | Default PRD location (repo root only) |
   | `/PLAN/` | Default PLAN location (repo root only) |
   | `/docs/PRD/` | Alternate PRD location (`prd_folder`) |
   | `/docs/PLAN/` | Reserved alternate; ignore preemptively |

   Use leading `/` so `skills/plan/` and other paths named `plan` are not ignored. Treat a pattern as present if `.gitignore` has an equivalent root-anchored line (or same effect).
3. If **any** of the four is missing, append the **full** block (do not add lines one at a time — keeps repos consistent):

   ```gitignore
   # SDD artifacts (local agent workflow — cursor-dev-toolkit)
   /PRD/
   /PLAN/
   /docs/PRD/
   /docs/PLAN/
   ```

4. Report: patterns added, or all four already present. Do not duplicate existing entries.

**Global mode:** do not modify project `.gitignore`.

## PRD / PLAN numbering

Collect existing files from **both** locations before assigning `NNN`:

| Location | Glob |
|----------|------|
| Workspace | `PRD/*.md`, `docs/PRD/*.md`, `PLAN/PLAN_*.md` |
| Global | `~/.cursor/sdd/<repo-id>/PRD/*.md`, `.../PLAN/PLAN_*.md` |

Use the highest `NNN` across all matches, then +1. PLAN `NNN` must match the source PRD sequence.

## Filenames

| Artifact | Pattern |
|----------|---------|
| PRD | `NNN_short_feature_slug.md` (3-digit `NNN`, ASCII slug; words from pt-BR titles allowed) |
| PLAN | `PLAN_NNN_short_feature_slug.md` |

## Handoff paths

Always pass the **full path** used on disk (relative to workspace or absolute for global):

```text
use skill plan — PRD/003_feature.md
use skill plan — ~/.cursor/sdd/acme-payments-api/PRD/003_feature.md

use skill implement — PLAN/PLAN_003_feature.md — Step 1
use skill implement — ~/.cursor/sdd/acme-payments-api/PLAN/PLAN_003_feature.md — Step 1
```

## Invalid paths and promotion

**Forbidden** as final SDD destinations: `~/.cursor/` outside `sdd/<repo-id>/`, `docs/backlog/`, generic `docs/*.md`, repo-root markdown without `NNN_` / `PLAN_NNN_` patterns.

When the user cites a non-canonical `.md`: read it, build the artifact per skill templates, confirm path (`PIPELINE.md` § Confirm before write), then `Write` only under `PRD/`, `docs/PRD/`, `PLAN/`, or global `~/.cursor/sdd/<repo-id>/PRD|PLAN/`.

Full rules: `PIPELINE.md` (order, mode phases, missing-artifact dialogs).

## Skill responsibilities

| Skill | Storage question | `.gitignore` | Writes |
|-------|------------------|--------------|--------|
| spec | Yes (or manifest) | Repository mode only | PRD + manifest |
| plan | Yes if manifest missing; infer if PRD is global | Repository mode only | PLAN + manifest |
| implement | No — use PLAN path from input | No | Updates same PLAN file |
| code-review | No | No | Read-only: manifest + glob repo/global; no writes |
| refine-backlog-item | No (escalates to `spec`) | No | Read-only when listing existing PRDs before handoff |
| breakdown-tasks | No | No | Read-only when resolving an existing SDD PLAN path |
| fix-build | No | No | Read-only optional — do not invent PRD/PLAN paths |
| plan-repo-docs / document-repo | No | No | **Do not** use this file for `docs/documentation-plan/plan.md` (RAG doc plan, not SDD) |

## Read-only discovery (other skills)

Use the same resolution as `code-review` (`skills/code-review/reference.md` § SDD artifact resolution) when a skill needs an **existing** SDD PRD or PLAN and the user did not pass a full path.

1. Read manifest when `workspace_root` matches the open workspace.
2. Glob **both** repository and `~/.cursor/sdd/<repo-id>/` (do not assume absence from an empty workspace `PRD/` alone).
3. Pair PRD and PLAN by `NNN` when both are needed.
4. Hand off with **full paths** (`use skill plan — PRD/003_x.md`, `use skill implement — PLAN/PLAN_003_x.md — Step 1`).
5. If zero or multiple pairs remain ambiguous after a full search, ask once in **pt-BR** in chat with numbered full paths.

**Not SDD:** `docs/documentation-plan/plan.md` and `docs/overview.md` belong to `plan-repo-docs` / `document-repo` only.

## Integration

- Pipeline guards: `skills/_shared/sdd-artifacts/PIPELINE.md`
- Templates: `skills/spec/reference.md`, `skills/plan/reference.md`
- SDD discovery (read-only): `skills/code-review/reference.md` § SDD artifact resolution
- Context rule: `rules/context-management.md`
- Always-on rule: `rules/sdd-pipeline-guards.md`
- Hooks: `hooks/_hook-common.ps1` (`Test-PlanFilePath` includes global PLAN paths)
