# Cursor agent router - cursor-dev-toolkit

Lean router for agents when this toolkit is installed under `~/.cursor/`. Pointers only - do not paste guideline bodies here.

## Language

| Context | Rule |
|---------|------|
| SDD agent artifacts (`PRD/*.md`, `PLAN/PLAN_*.md`, `.specify/specs/**`) | Brazilian Portuguese (pt-BR) - `sdd-artifact-language-pt-br.mdc` |
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
| sdd-spec | `use skill sdd-spec` | `features/NNN-slug/.../PRD/` (or legacy `PRD/`) |
| sdd-plan | `use skill sdd-plan` | `features/.../PLAN/PLAN_XXX.md` |
| sdd-develop | `use skill sdd-develop` | Code + PLAN checkbox |

### Forma C - multi-agent orchestration

```
orchestrate-analyze (O1) -> human approve backlog
  -> orchestrate-deliver (O2) -> human approve PRD/PLAN per story
  -> orchestrate-develop (O3) OR manual sdd-develop
  -> optional code-review (multi-angle)
```

| Skill | Invoke | Typical output |
|-------|--------|----------------|
| orchestrate-analyze | `use skill orchestrate-analyze` | `FEATURE.md` + US/TS + `CONTINUITY.md` |
| orchestrate-deliver | `use skill orchestrate-deliver - <feature-path>` | PRD/PLAN per story + path handoff |
| orchestrate-develop | `use skill orchestrate-develop - <feature-path>` | One PLAN step per subagent; CONTINUITY |

O1/O2 do **not** write app code. O3 parent does **not** implement; children reuse the `sdd-develop` contract.

### Spec Kit SDD

```
speckit-setup -> speckit-init -> speckit-spec -> speckit-plan -> speckit-develop
```

| Skill | Invoke | Typical output |
|-------|--------|----------------|
| speckit-setup | `use skill speckit-setup` | CLI prerequisites |
| speckit-init | `use skill speckit-init` | `.specify/` + `constitution.md` |
| speckit-spec | `use skill speckit-spec` | `.specify/specs/NNN-<slug>/spec.md` |
| speckit-plan | `use skill speckit-plan` | `plan.md` + `tasks.md` |
| speckit-develop | `use skill speckit-develop` | Code + tasks checkbox |

**Out of this MVP (Forma C / PRD 003):** Spec Kit path changes, full `memory-bank/`, git worktrees multi-US. Spec Kit skills remain fully usable as today.

**Checkpoint:** one `sdd-develop` / `speckit-develop` session = one step/task.

**Enforcement:** `~/.cursor/rules/guardrails.mdc`, `sdd-pipeline-guards.mdc`, `SESSION.md` session gates.

### Shortcut - small work

`developer` - `use skill developer` routes to the correct stack skill (or fallback for ad-hoc scripts).

For explicit .NET work: `dotnet-developer` - `use skill dotnet-developer`.

For frontend UI design (shape, audit, polish): `impeccable` - `use skill impeccable`. Handoff via `docs/DESIGN-BRIEF.md` to stack `*-developer` skills (`react`, `angular`, `vue`, `blazor`, `electron`, `javascript`).

For new Blip React plugins: `blip-plugin-developer` - `use skill blip-plugin-developer`. Handoff to `react-developer` + `blip-guidelines/`. See `docs/blip-plugin-integration.md`.

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

See full list: `docs/SKILLS.md` in the toolkit repo.

| Skill | Invoke |
|-------|--------|
| impeccable | `use skill impeccable` |
| blip-plugin-developer | `use skill blip-plugin-developer` |
| sdd-spec | `use skill sdd-spec` |
| sdd-plan | `use skill sdd-plan` |
| sdd-develop | `use skill sdd-develop` |
| orchestrate-analyze | `use skill orchestrate-analyze` |
| orchestrate-deliver | `use skill orchestrate-deliver` |
| orchestrate-develop | `use skill orchestrate-develop` |
| speckit-setup | `use skill speckit-setup` |
| speckit-init | `use skill speckit-init` |
| speckit-spec | `use skill speckit-spec` |
| speckit-plan | `use skill speckit-plan` |
| speckit-develop | `use skill speckit-develop` |
| developer | `use skill developer` |
| dotnet-developer | `use skill dotnet-developer` |
| react-developer | `use skill react-developer` |
| angular-developer | `use skill angular-developer` |
| vue-developer | `use skill vue-developer` |
| blazor-developer | `use skill blazor-developer` |
| electron-developer | `use skill electron-developer` |
| javascript-developer | `use skill javascript-developer` |
| python-developer | `use skill python-developer` |
| code-review | `use skill code-review` |
| fix-build | `use skill fix-build` |
| test-coverage | `use skill test-coverage` |
| commit | `use skill commit` |
| push | `use skill push` |
| add-migrations | `use skill add-migrations` |
| create-message-consumer | `use skill create-message-consumer` |
| refactor | `use skill refactor` |
| api-integrate | `use skill api-integrate` |
| performance-profile | `use skill performance-profile` |
| containerize | `use skill containerize` |
| i18n-manager | `use skill i18n-manager` |
| document-plan | `use skill document-plan` |
| document-implement | `use skill document-implement` |
| refine-backlog-item | `use skill refine-backlog-item` |
| breakdown-tasks | `use skill breakdown-tasks` |

## Post-sync validation

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validation\validate-all.ps1
```

Or use the interactive menu: `.\scripts\toolkit.ps1`

Maintainer guide: `docs/MAINTAINER_GUIDE.md` · Install: `docs/INSTALL.md` · Impeccable: `docs/impeccable-integration.md` · Blip plugins: `docs/blip-plugin-integration.md` · Enforcement: `docs/ENFORCEMENT.md`
