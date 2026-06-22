# Install and usage guide

Step-by-step instructions to deploy **cursor-dev-toolkit** to Cursor and use the SDD workflow in any project.

## Prerequisites

| Requirement | Notes |
|-------------|--------|
| **Cursor IDE** | Skills and rules target Cursor's `~/.cursor/` layout |
| **Windows** | Hooks and sync script use **PowerShell 5.1+** |
| **Git** | Optional; only needed to clone/update this repo |

> **macOS / Linux:** Skills and rules sync work with `$HOME/.cursor/`. Hooks are PowerShell-only today.

---

## 1. Clone and deploy

```powershell
cd cursor-dev-toolkit
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
```

Preview: add `-DryRun`.

### Post-deploy validation

```powershell
.\scripts\validate-all.ps1
```

Optional Spec Kit / session checks:

```powershell
.\scripts\validate-all.ps1 -IncludeSpeckit -RepoPath "D:\Source\Repos\MyApp"
.\scripts\validate-all.ps1 -IncludeSessionGate -RepoPath "D:\Source\Repos\MyApp"
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
| PRD | `use skill sdd-spec` |
| PLAN | `use skill sdd-plan - <prd-path>` |
| Develop | `use skill sdd-develop - <plan-path> - Step N` |

### Spec Kit

| Step | Invoke |
|------|--------|
| Setup | `use skill speckit-setup` |
| Init | `use skill speckit-init` |
| Spec | `use skill speckit-spec` |
| Plan | `use skill speckit-plan - <spec-path>` |
| Develop | `use skill speckit-develop - <tasks-path>` |

### Shortcut

`use skill developer` - small work without full SDD.

### Storage

Unified manifest v2: `~/.cursor/sdd/manifest.json` with `classic` and `speckit` sections. See `STORAGE.md` and `docs/ENFORCEMENT.md`.

Configure a repo:

```powershell
.\scripts\setup-speckit.ps1
.\scripts\configure-repo-sdd.ps1 -StorageMode global -RepoPath "D:\Source\Repos\MyApp"
```

Migrate legacy manifest:

```powershell
.\scripts\migrate-manifest-v2.ps1
```

---

## 5. Rules summary

| Rule | Effect |
|------|--------|
| `guardrails.mdc` | Git block, confirm-before-write, session gates |
| `sdd-pipeline-guards.mdc` | SDD order and canonical paths |
| `user-language-pt-br.mdc` | Chat in pt-BR |
| `sdd-artifact-language-pt-br.mdc` | PRD/PLAN/spec/plan/tasks default pt-BR |
| `branch-validation.mdc` | Valid branch before commit/push |
| `context-management.mdc` | Pause at 40%/80% context |

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

Maintainer: [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md) · Catalog: [SKILLS.md](SKILLS.md)
