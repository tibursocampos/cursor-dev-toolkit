# Install and usage guide

Step-by-step instructions to deploy **cursor-dev-toolkit** to Cursor and use the SDD workflow in any project.

## Prerequisites

| Requirement | Notes |
|-------------|--------|
| **Cursor IDE** | Skills and rules target Cursor's `~/.cursor/` layout |
| **Windows** | Hooks and sync script use **PowerShell 5.1+** (Windows PowerShell or `pwsh`) |
| **Git** | Optional; only needed to clone/update this repo |
| **This repo cloned** | Any local path (example: `D:\Source\Repos\cursor-dev-toolkit`) |

> **macOS / Linux:** Skills and rules sync work if you adapt paths (`$HOME/.cursor/`). Hooks are PowerShell-only today; skip hooks or port scripts separately.

---

## 1. Clone the toolkit

```powershell
git clone <your-remote-url> cursor-dev-toolkit
cd cursor-dev-toolkit
```

If you already have the folder, `cd` to the repo root (where `AGENTS.md` and `scripts/` live).

---

## 2. Deploy to `~/.cursor/`

From the **repo root**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
```

Preview without writing files:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1 -DryRun
```

### What gets installed

| Source (this repo) | Installed path | Behavior |
|--------------------|----------------|----------|
| `AGENTS.md` | `~/.cursor/AGENTS.md` | Overwritten when content hash changes |
| `skills/` (entire tree) | `~/.cursor/skills/` | Per-file sync; does **not** delete your other skills |
| `rules/*.md` | `~/.cursor/rules/*.mdc` | Extension renamed `.md` → `.mdc` |
| `hooks/*.ps1` | `~/.cursor/hooks/` | Hook scripts |
| `hooks/hooks.json` | `~/.cursor/hooks.json` | **Merged** by `command` string; existing entries kept |

### What is never touched

- `~/.cursor/settings.json`, `mcp.json`, extensions, projects cache
- Unrelated files already under `~/.cursor/`

### After sync

- Re-run the same command after `git pull` in this repo (idempotent SHA-256 compare).
- If `hooks.json` changed, restart Cursor or reload hooks.

---

## 3. Verify installation

Check these paths exist (Windows example):

```
%USERPROFILE%\.cursor\AGENTS.md
%USERPROFILE%\.cursor\skills\spec\SKILL.md
%USERPROFILE%\.cursor\skills\implement\SKILL.md
%USERPROFILE%\.cursor\rules\user-language-pt-br.mdc
%USERPROFILE%\.cursor\hooks.json
```

Optional: smoke-test hooks from repo root — see [HOOKS.md](HOOKS.md).

---

## 4. Use in a project

Open **any codebase** in Cursor (not necessarily this toolkit repo).

**Daily usage:** step-by-step skill manuals live in **[guides/README.md](guides/README.md)** (decision tree + guides 01–05). The sections below are a short index; follow the guides for invokes, examples, and common mistakes.

### 4.1 SDD workflow (medium/high complexity)

| Step | Invoke | Guide |
|------|--------|-------|
| PRD | `use skill spec` | [01 — SDD workflow](guides/01-sdd-workflow.md) |
| PLAN | `use skill plan — <prd-path>` | [01 — SDD workflow](guides/01-sdd-workflow.md) |
| Implement | `use skill implement — <plan-path> — Step N` | [01 — SDD workflow](guides/01-sdd-workflow.md) |

**Rules (summary):** one `implement` session = **one** PLAN step; new chat per step; confirm **sim** in Agent before PRD/PLAN writes. At ~40% context, pause and start a new chat (see [guide 01](guides/01-sdd-workflow.md)).

**Storage:** repo `PRD/` and `PLAN/` (gitignored) **or** global `~/.cursor/sdd/<repo-id>/` — details in [guide 01](guides/01-sdd-workflow.md) and `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md`.

### 4.2 Small .NET change (no PRD)

```
use skill dotnet-developer
```

Details: [02 — dotnet-developer](guides/02-dotnet-developer.md)

### 4.3 Commit, review, and coverage

| Task | Invoke | Guide |
|------|--------|-------|
| Review diff vs PRD/PLAN | `use skill code-review` | [03 — code-review](guides/03-code-review.md) |
| Coverage report (.NET) | `use skill test-coverage` | [04 — test-coverage](guides/04-test-coverage.md) |
| Conventional commit + push | `use skill commit` | [05 — operational skills](guides/05-operational-skills.md) |

Branch rules: `feature/<slug>` or `feat/<id>` only — not `main` / `master` / `develop`.

Post-code order: `code-review` → `test-coverage` → `commit` — see [guides/README.md](guides/README.md#post-code-workflow).

### 4.4 Other operational skills

All run in the **open workspace** (the project you are building). None require Azure DevOps, Jira APIs, or PAT scripts.

**Language:** skills that write product `docs/` in the target repo ask **pt-BR** or **English** before saving.

| Skill | Invoke |
|-------|--------|
| `fix-build` | `use skill fix-build` |
| `add-migrations` | `use skill add-migrations` |
| `plan-repo-docs` | `use skill plan-repo-docs` |
| `document-repo` | `use skill document-repo` |
| `refine-backlog-item` | `use skill refine-backlog-item` |
| `breakdown-tasks` | `use skill breakdown-tasks` |
| `create-message-consumer` | `use skill create-message-consumer` |

Full mini-manuals, suggested flows (RAG repo docs, backlog → SDD, fix-build → commit), and handoffs: **[05 — operational skills](guides/05-operational-skills.md)**.

> **Note:** `plan-repo-docs` / `document-repo` document **application repositories** for RAG. They are not a substitute for toolkit user guides under `docs/guides/`.

---

## 5. Language and rules

| Rule file | Effect |
|-----------|--------|
| `user-language-pt-br.mdc` | Agent replies in **Brazilian Portuguese** in chat |
| `sdd-artifact-language-pt-br.mdc` | PRD/PLAN agent `.md` in **pt-BR** by default; **code always English**; ask language for project `docs/` |
| `conventional-commits.mdc` | Commit message format |
| `branch-validation.mdc` | Branch name before commit/push |
| `context-management.mdc` | Multi-step session / compaction checkpoints |

Source files live in this repo under `rules/`; installed names end with `.mdc`.

---

## 6. Optional hooks

Hooks track SDD skill usage and remind you before context compaction. They do **not** select models.

- Details: [HOOKS.md](HOOKS.md)
- Installed automatically by `sync-cursor.ps1` (section 2)

---

## 7. Troubleshooting

| Problem | Action |
|---------|--------|
| Skills not found | Re-run `sync-cursor.ps1`; confirm `~/.cursor/skills/spec/SKILL.md` exists |
| Rules ignored | Confirm `~/.cursor/rules/*.mdc` exist; restart Cursor |
| `ExecutionPolicy` blocks script | Use `-ExecutionPolicy Bypass` as in examples above |
| Hooks not firing | Check `~/.cursor/hooks.json` has **array** entries per event; restart Cursor |
| Agent replies in English | Ensure `user-language-pt-br.mdc` is installed |
| PRD/PLAN saved in English unexpectedly | Ensure `sdd-artifact-language-pt-br.mdc` is installed; new chat after sync; override only with `em inglês` in invocation |
| Sync always says "up to date" but files old | Run without `-DryRun`; delete target file and sync again if needed |

---

## 8. Maintainer: update the toolkit

1. Edit files in `cursor-dev-toolkit` clone.
2. Confirm each `skills/*/SKILL.md` is ≤ 150 lines (see [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md)).
3. `powershell -File scripts/sync-cursor.ps1`
4. New Cursor chat in consumer projects picks up skills/rules.

Repository layout and extension checklist: [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md).
