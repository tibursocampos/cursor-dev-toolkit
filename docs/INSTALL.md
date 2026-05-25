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

## 4. Use in a project (SDD workflow)

Open **any codebase** in Cursor (not necessarily this toolkit repo). In chat:

### 4.1 New feature (medium/high complexity)

| Step | You say | Agent produces |
|------|---------|----------------|
| 1 | `use skill spec` + describe the feature | PRD in repo (`PRD/` or `docs/PRD/`) **or** global (`~/.cursor/sdd/<repo-id>/PRD/`) |
| 2 | `use skill plan` + point to the PRD (full path) | PLAN in repo (`PLAN/`) **or** global (`~/.cursor/sdd/<repo-id>/PLAN/`) |
| 3 | `use skill implement — <full-plan-path> — Step 1` | Code + tests for **one** PLAN step only |
| 4 | New chat for each next step | `use skill implement — <full-plan-path> — Step 2`, etc. |

Before the first write, the agent asks where to store PRD/PLAN:

1. **Repository** — `PRD/` and `PLAN/` at project root (or `docs/PRD/` for PRD); `.gitignore` gets `/PRD/`, `/PLAN/`, `/docs/PRD/`, and `/docs/PLAN/` on first SDD write (`spec` / `plan` per `STORAGE.md`).
2. **Global** — outside the project git tree under `~/.cursor/sdd/<repo-id>/` (use when the repo cannot contain or ignore SDD folders).

Details: `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` (synced with the toolkit).

**Rules:**

- One `implement` session = **one** PLAN step.
- Update PLAN progress before starting the next step (implement skill does this).
- At ~40% context usage, pause and start a new chat (see `context-management` rule).

### 4.2 Small .NET change (no PRD)

```
use skill dotnet-developer
```

Describe the fix/refactor; agent loads `dotnet-guidelines` on demand.

### 4.3 Commit and review

| Task | Invoke |
|------|--------|
| Conventional commit + push | `use skill commit` |
| Review diff vs PRD/PLAN | `use skill code-review` (discovers artifacts per `STORAGE.md` in repo or `~/.cursor/sdd/<repo-id>/`) |

Branch rules: `feature/<slug>` or `feat/<id>` only — not `main` / `master` / `develop`.

### 4.4 Operational skills (no work-item tracker)

All run in the **open workspace** (the project you are building). None require Azure DevOps, Jira APIs, or PAT scripts.

| Skill | Invoke | Use for |
|-------|--------|---------|
| `add-migrations` | `use skill add-migrations` | Add EF Core migration (Glob/Grep discovery) |
| `fix-build` | `use skill fix-build` | Diagnose/fix `dotnet build` or test failures; optional `gh` for CI logs |
| `plan-repo-docs` | `use skill plan-repo-docs` | Create `docs/documentation-plan/plan.md` + overview |
| `document-repo` | `use skill document-repo` | Execute next pending step in the doc plan |
| `refine-backlog-item` | `use skill refine-backlog-item` | Bug / User Story / Technical Story markdown + scorecard |
| `breakdown-tasks` | `use skill breakdown-tasks` | Group steps → `docs/implementation-tasks/<slug>.md` |
| `create-message-consumer` | `use skill create-message-consumer` | Scaffold consumer (MassTransit/RabbitMQ/etc. via Grep) |

**Language:** skills that write product `docs/` in the target repo ask **pt-BR** or **English** before saving.

**Suggested flows:**

```
use skill plan-repo-docs
use skill document-repo
```

```
use skill refine-backlog-item
use skill breakdown-tasks
use skill spec
use skill plan
```

```
use skill fix-build
use skill commit
```

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
