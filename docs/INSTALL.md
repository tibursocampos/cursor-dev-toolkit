# Install and usage guide

Step-by-step instructions to deploy **cursor-dev-toolkit** to Cursor and use the SDD workflow in any project.

> **Repository policy:** public — clone and fork freely. **No upstream contributions** (do not open PRs here). See [CONTRIBUTING.md](../CONTRIBUTING.md).

## Prerequisites

| Requirement | Notes |
|-------------|--------|
| **Cursor IDE** | Skills and rules target Cursor's `~/.cursor/` layout |
| **PowerShell** | Windows: **5.1+** or **pwsh 7+**. macOS/Linux: **pwsh 7+** required (see [install guide](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)) |
| **Git** | Optional; only needed to clone/update this repo |

> **macOS / Linux:** Install `pwsh`, then use `./scripts/toolkit.sh` or `./scripts/sync-cursor.sh`. Skills/rules sync to `$HOME/.cursor/`.

---

## 1. Clone and deploy

**Recommended:** interactive toolkit CLI (both platforms):

```powershell
# Windows
cd cursor-dev-toolkit
.\scripts\toolkit.ps1
```

```bash
# macOS / Linux
cd cursor-dev-toolkit
chmod +x scripts/*.sh scripts/validation/*.sh
./scripts/toolkit.sh
```

Direct sync:

```powershell
# Windows
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
```

```bash
# macOS / Linux
./scripts/sync-cursor.sh
```

Preview: add `-DryRun` to the `.ps1` (or pass through the `.sh` wrapper).

Uninstall (removes toolkit from `~/.cursor/`):

```powershell
.\scripts\uninstall-toolkit.ps1 -DryRun
.\scripts\uninstall-toolkit.ps1
```

### Post-deploy validation

```powershell
.\scripts\validation\validate-all.ps1
```

Optional session-gate checks:

```powershell
.\scripts\validation\validate-all.ps1 -IncludeSessionGate -RepoPath "D:\Source\Repos\MyApp"
```

---

## 2. What gets installed

| Source | Installed path |
|--------|----------------|
| `AGENTS.md` | `~/.cursor/AGENTS.md` |
| `skills/` | `~/.cursor/skills/` |
| `rules/*.md` | `~/.cursor/rules/*.mdc` |
| `hooks/` | `~/.cursor/hooks/` + merged `hooks.json` |
| SDD sessions dir | `~/.cursor/sdd/sessions/` (created on sync) |

---

## 3. Verify installation

```
%USERPROFILE%\.cursor\AGENTS.md
%USERPROFILE%\.cursor\skills\sdd-spec\SKILL.md
%USERPROFILE%\.cursor\rules\guardrails.mdc
%USERPROFILE%\.cursor\skills\_shared\sdd-artifacts\SESSION.md
```

---

## 4. Use in a project

Open any codebase in Cursor. Manuals: **[guides/README.md](guides/README.md)**.

### Classic SDD

| Step | Invoke |
|------|--------|
| PRD | `/sdd-spec` |
| PLAN | `/sdd-plan - <prd-path>` |
| Develop | `/sdd-develop - <plan-path> - Step N` |

### Shortcut

`/developer` - routes to the correct stack skill for small work without full SDD.

Explicit .NET: `/dotnet-developer`.

New Blip React plugin: `/blip-plugin-developer` (see [blip-plugin-integration.md](blip-plugin-integration.md)).

Net-new UI: `/impeccable shape` -> `docs/DESIGN-BRIEF.md` (see [impeccable-integration.md](impeccable-integration.md)).

### Storage

Unified manifest v2: `~/.cursor/sdd/manifest.json` with a `classic` section per repo (legacy `speckit` keys are ignored). See `STORAGE.md` and `docs/ENFORCEMENT.md`.

Configure a repo:

```powershell
.\scripts\configure-repo-sdd.ps1 -StorageMode global -RepoPath "D:\Source\Repos\MyApp"
```

Migrate legacy manifest:

```powershell
.\scripts\maintainers\migrate-manifest-v2.ps1
```

> **Breaking change (PRD 004):** Spec Kit is removed from the operational toolkit.
>
> - **Removed:** skills `speckit-setup|init|spec|plan|develop`, `scripts/setup-speckit.ps1`, `validate-speckit-init.ps1`, `fix-speckit-refs.ps1`, guide `docs/guides/06-speckit-workflow.md`, Spec Kit menu entries, and `.specify` / `specify-cli` paths in STORAGE/PIPELINE/SESSION.
> - **Use instead:** Formas A / B / C only (`sdd-*`, backlog prep, `orchestrate-*`).
> - **Added:** `memory-bank-init` + Memory Bank Gate (Step 0) on Forma C O1/O2/O3; O3 Step N `refresh-light`. Bank co-locates with `features/` via manifest; local only (`/memory-bank/` gitignored in repository mode). Forma A does **not** require a memory-bank.
> - **Manifest:** legacy `speckit` keys in `~/.cursor/sdd/manifest.json` are **ignored** - remove manually if desired; no forced migrate.
> - **After pull:** `.\scripts\sync-cursor.ps1` then `.\scripts\validation\validate-all.ps1` (expect **34** skills).

---

## 5. Rules summary

| Rule | Effect |
|------|--------|
| `guardrails.mdc` | Git block, confirm-before-write, session gates |
| `ai-stealth.mdc` | No AI traces in code, docs, commits, identifiers |
| `sdd-pipeline-guards.mdc` | SDD order and canonical paths |
| `user-language-pt-br.mdc` | Chat in pt-BR |
| `sdd-artifact-language-pt-br.mdc` | PRD/PLAN default pt-BR |
| `branch-validation.mdc` | Valid branch before commit/push |
| `conventional-commits.mdc` | Conventional Commits format |
| `context-management.mdc` | Pause at 40%/80% context |
| `caveman-mode.mdc` | Optional response compression |

---

## 6. Optional hooks

See [HOOKS.md](HOOKS.md). Installed by `sync-cursor.ps1`.

---

## 7. Troubleshooting

| Problem | Action |
|---------|--------|
| Skills not found | Re-run sync; check `~/.cursor/skills/sdd-spec/SKILL.md` |
| Validation fails | Run `validate-all.ps1`; fix reported paths |
| Hooks not firing | Restart Cursor after `hooks.json` merge |

Maintainer: [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md) · Catalog: [SKILLS.md](SKILLS.md) · Impeccable: [impeccable-integration.md](impeccable-integration.md) · Blip: [blip-plugin-integration.md](blip-plugin-integration.md)
