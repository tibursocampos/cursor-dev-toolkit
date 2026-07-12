# Cursor agent router - cursor-dev-toolkit

Lean router for agents when this toolkit is installed under `~/.cursor/`. Pointers only - do not paste guideline bodies here.

## Language

| Context | Rule |
|---------|------|
| SDD agent artifacts (`features/**` — FEATURE/STORY/PRD/PLAN/CONTINUITY; `.specify/specs/**`) | Brazilian Portuguese (pt-BR) - `sdd-artifact-language-pt-br.mdc` |
| Source code, tests, commits, identifiers | English always |
| Project docs (`docs/`, README deliverables) | Ask pt-BR or English in skill before writing |
| User-facing chat replies | Brazilian Portuguese (pt-BR) - `user-language-pt-br.mdc` |

## Workflows

Three coexisting **Formas** (none deprecates another). New Classic / Forma C writes land under `features/NNN-slug/` (see `STORAGE.md`).

| Forma | When | Pipeline |
|-------|------|----------|
| **A** Classic SDD | One feature, clear path | `sdd-spec` -> `sdd-plan` -> `sdd-develop` |
| **B** Backlog prep | Informal item before SDD | `refine-backlog-item` -> `breakdown-tasks` -> A or C |
| **C** Orchestrated | Multi-story / brownfield / specialists | `orchestrate-analyze` -> `orchestrate-deliver` -> (`orchestrate-develop` \| `sdd-develop`) |

Guide: `docs/guides/10-forma-c-orquestracao.md` (Forma C + walkthrough NuGet).

### Classic SDD (Forma A)

```
sdd-spec -> sdd-plan -> sdd-develop (one PLAN step per session)
```

| Skill | Invoke | Typical output |
|-------|--------|----------------|
| sdd-spec | `/sdd-spec` | `features/NNN-slug/USnn/PRD/` |
| sdd-plan | `/sdd-plan` | `features/.../PLAN/PLAN_XXX.md` |
| sdd-develop | `/sdd-develop` | Code + PLAN checkbox |

### Forma C - multi-agent orchestration

```
orchestrate-analyze (O1) -> human approve backlog
  -> orchestrate-deliver (O2) -> human approve PRD/PLAN per story
  -> orchestrate-develop (O3) OR manual sdd-develop
  -> optional code-review (asks single vs multi-angle if omitted)
```

| Skill | Invoke | Typical output |
|-------|--------|----------------|
| orchestrate-analyze | `/orchestrate-analyze` | `FEATURE.md` + US/TS + `CONTINUITY.md` |
| orchestrate-deliver | `/orchestrate-deliver - <feature-path>` | PRD/PLAN per story + path handoff |
| orchestrate-develop | `/orchestrate-develop - <feature-path>` | One PLAN step per subagent; CONTINUITY |

O1/O2 do **not** write app code. O3 parent does **not** implement; children reuse the `sdd-develop` contract.

### Spec Kit SDD

```
speckit-setup -> speckit-init -> speckit-spec -> speckit-plan -> speckit-develop
```

| Skill | Invoke | Typical output |
|-------|--------|----------------|
| speckit-setup | `/speckit-setup` | CLI prerequisites |
| speckit-init | `/speckit-init` | `.specify/` + `constitution.md` |
| speckit-spec | `/speckit-spec` | `.specify/specs/NNN-<slug>/spec.md` |
| speckit-plan | `/speckit-plan` | `plan.md` + `tasks.md` |
| speckit-develop | `/speckit-develop` | Code + tasks checkbox |

**Out of this MVP (Forma C / PRD 003):** Spec Kit path changes, full `memory-bank/`, git worktrees multi-US. Spec Kit skills remain fully usable as today.

**Checkpoint:** one `sdd-develop` / `speckit-develop` session = one step/task.

**Enforcement:** `~/.cursor/rules/guardrails.mdc`, `sdd-pipeline-guards.mdc`, `SESSION.md` session gates.

### Shortcut - small work

`developer` - `/developer` routes to the correct stack skill (or fallback for ad-hoc scripts).

For explicit .NET work: `dotnet-developer` - `/dotnet-developer`.

For frontend UI design (shape, audit, polish): `impeccable` - `/impeccable`. Handoff via `docs/DESIGN-BRIEF.md` to stack `*-developer` skills (`react`, `angular`, `vue`, `blazor`, `electron`, `javascript`).

For new Blip React plugins: `blip-plugin-developer` - `/blip-plugin-developer`. Handoff to `react-developer` + `blip-guidelines/`. See `docs/blip-plugin-integration.md`.

### Optional flows

| Flow | Steps |
|------|--------|
| Forma C (complex / multi-story) | `orchestrate-analyze` -> `orchestrate-deliver` -> `orchestrate-develop` \| `sdd-develop` |
| Repo documentation (RAG) | `document-plan` -> `document-implement` |
| Backlog -> SDD (Forma B) | `refine-backlog-item` -> `breakdown-tasks` -> classic, Spec Kit, or Forma C |
| Frontend design -> implement | `impeccable shape` -> `DESIGN-BRIEF.md` -> `*-developer` (one session per step) |
| Blip plugin scaffold -> implement | `blip-plugin-developer` -> SDD/spec -> `react-developer` (one session per step) |
| Build / test | `fix-build` -> optional `commit` / `push` |
| EF migration | `add-migrations` |
| Message consumer | `create-message-consumer` |

## Rules (always-on)

| Rule | Path |
|------|------|
| Guardrails (git, write, gates) | `~/.cursor/rules/guardrails.mdc` |
| AI stealth | `~/.cursor/rules/ai-stealth.mdc` |
| SDD pipeline | `~/.cursor/rules/sdd-pipeline-guards.mdc` |
| Context management | `~/.cursor/rules/context-management.mdc` |
| SDD artifact language | `~/.cursor/rules/sdd-artifact-language-pt-br.mdc` |
| User chat language | `~/.cursor/rules/user-language-pt-br.mdc` |
| Branch / commits | `branch-validation.mdc`, `conventional-commits.mdc` |
| Caveman Mode | `caveman-mode.mdc` |

## Skills catalog (38)

See full list: `docs/SKILLS.md` in the toolkit repo. Prefer `/<name>` (Cursor slash menu). Compat: `use skill <name>` still works.

| Skill | Invoke |
|-------|--------|
| impeccable | `/impeccable` |
| blip-plugin-developer | `/blip-plugin-developer` |
| sdd-spec | `/sdd-spec` |
| sdd-plan | `/sdd-plan` |
| sdd-develop | `/sdd-develop` |
| orchestrate-analyze | `/orchestrate-analyze` |
| orchestrate-deliver | `/orchestrate-deliver` |
| orchestrate-develop | `/orchestrate-develop` |
| speckit-setup | `/speckit-setup` |
| speckit-init | `/speckit-init` |
| speckit-spec | `/speckit-spec` |
| speckit-plan | `/speckit-plan` |
| speckit-develop | `/speckit-develop` |
| developer | `/developer` |
| dotnet-developer | `/dotnet-developer` |
| react-developer | `/react-developer` |
| angular-developer | `/angular-developer` |
| vue-developer | `/vue-developer` |
| blazor-developer | `/blazor-developer` |
| electron-developer | `/electron-developer` |
| javascript-developer | `/javascript-developer` |
| python-developer | `/python-developer` |
| code-review | `/code-review` |
| fix-build | `/fix-build` |
| test-coverage | `/test-coverage` |
| commit | `/commit` |
| push | `/push` |
| add-migrations | `/add-migrations` |
| create-message-consumer | `/create-message-consumer` |
| refactor | `/refactor` |
| api-integrate | `/api-integrate` |
| performance-profile | `/performance-profile` |
| containerize | `/containerize` |
| i18n-manager | `/i18n-manager` |
| document-plan | `/document-plan` |
| document-implement | `/document-implement` |
| refine-backlog-item | `/refine-backlog-item` |
| breakdown-tasks | `/breakdown-tasks` |

## Post-sync validation

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validation\validate-all.ps1
```

Or use the interactive menu: `.\scripts\toolkit.ps1`

Maintainer guide: `docs/MAINTAINER_GUIDE.md` · Install: `docs/INSTALL.md` · Impeccable: `docs/impeccable-integration.md` · Blip plugins: `docs/blip-plugin-integration.md` · Enforcement: `docs/ENFORCEMENT.md`
