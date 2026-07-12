# Cursor agent router - cursor-dev-toolkit

Lean router for agents when this toolkit is installed under `~/.cursor/`. Pointers only - do not paste guideline bodies here.

## Language

| Context | Rule |
|---------|------|
| SDD agent artifacts (`features/**` - FEATURE/STORY/PRD/PLAN/CONTINUITY) | Brazilian Portuguese (pt-BR) - `sdd-artifact-language-pt-br.mdc` |
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
Step 0 memory-bank gate (auto) -> orchestrate-analyze (O1) -> human approve backlog
  -> orchestrate-deliver (O2) -> human approve PRD/PLAN per story
  -> orchestrate-develop (O3) OR manual sdd-develop
  -> optional code-review (asks single vs multi-angle if omitted)
```

| Skill | Invoke | Typical output |
|-------|--------|----------------|
| memory-bank-init | `/memory-bank-init` | Repo-root `memory-bank/` (create/refresh) |
| orchestrate-analyze | `/orchestrate-analyze` | Step 0 + `FEATURE.md` + US/TS + `CONTINUITY.md` |
| orchestrate-deliver | `/orchestrate-deliver - <feature-path>` | Step 0 + PRD/PLAN per story + path handoff |
| orchestrate-develop | `/orchestrate-develop - <feature-path>` | Step 0 + one PLAN step per subagent; CONTINUITY |

**Step 0:** O1/O2/O3 run Memory Bank Gate before triage/deliver/develop (`MEMORY-BANK.md`). Forma A (`sdd-*`) does **not** require it. Bank lives at consumer `$Cwd/memory-bank/` - never under `features/`.

O1/O2 do **not** write app code. O3 parent does **not** implement; children reuse the `sdd-develop` contract.

**Checkpoint:** one `sdd-develop` session = one PLAN step.

**Enforcement:** `~/.cursor/rules/guardrails.mdc`, `sdd-pipeline-guards.mdc`, `SESSION.md` session gates.

### Shortcut - small work

`developer` - `/developer` routes to the correct stack skill (or fallback for ad-hoc scripts).

For explicit .NET work: `dotnet-developer` - `/dotnet-developer`.

For frontend UI design (shape, audit, polish): `impeccable` - `/impeccable`. Handoff via `docs/DESIGN-BRIEF.md` to stack `*-developer` skills (`react`, `angular`, `vue`, `blazor`, `electron`, `javascript`).

For new Blip React plugins: `blip-plugin-developer` - `/blip-plugin-developer`. Handoff to `react-developer` + `blip-guidelines/`. See `docs/blip-plugin-integration.md`.

### Optional flows

| Flow | Steps |
|------|--------|
| Forma C (complex / multi-story) | Step 0 memory-bank -> `orchestrate-analyze` -> `orchestrate-deliver` -> `orchestrate-develop` \| `sdd-develop` |
| Memory bank (manual) | `memory-bank-init` (create/refresh; also Step 0 inside O*) |
| Repo documentation (RAG) | `document-plan` -> `document-implement` |
| Backlog -> SDD (Forma B) | `refine-backlog-item` -> `breakdown-tasks` -> Forma A or Forma C |
| Frontend design -> implement | `impeccable shape` -> `DESIGN-BRIEF.md` -> `*-developer` (one session per step) |
| Blip plugin scaffold -> implement | `blip-plugin-developer` -> SDD -> `react-developer` (one session per step) |
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

## Skills catalog (34)

See full list: `docs/SKILLS.md` in the toolkit repo. Prefer `/<name>` (Cursor slash menu). Compat: `use skill <name>` still works.

| Skill | Invoke |
|-------|--------|
| impeccable | `/impeccable` |
| blip-plugin-developer | `/blip-plugin-developer` |
| sdd-spec | `/sdd-spec` |
| sdd-plan | `/sdd-plan` |
| sdd-develop | `/sdd-develop` |
| memory-bank-init | `/memory-bank-init` |
| orchestrate-analyze | `/orchestrate-analyze` |
| orchestrate-deliver | `/orchestrate-deliver` |
| orchestrate-develop | `/orchestrate-develop` |
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
