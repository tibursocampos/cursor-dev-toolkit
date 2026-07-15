# cursor-dev-toolkit

Personal Cursor IDE agent toolkit: SDD workflows (Formas A / B / C), .NET guidelines, Git-only developer flow, Caveman response compression, and optional hooks. Neutral branding - no work-item tracker or corporate pipeline integrations.

Deploy to your user profile with `scripts/sync-cursor.ps1` (see [docs/INSTALL.md](docs/INSTALL.md)).

## What this is

| Capability | Description |
|------------|-------------|
| **SDD workflow** | Classic Forma A (`sdd-spec` -> `sdd-plan` -> `sdd-develop`), Forma B backlog prep, Forma C orchestration; manifest v2 storage |
| **Enforcement** | `guardrails.mdc`, session gates, `validate-all.ps1` smoke test |
| **.NET guidelines** | `dotnet-guidelines` (Clean Architecture, xUnit, Moq, FluentAssertions) |
| **Git-only flow** | Branching, commits, checklist - no Azure DevOps |
| **Cursor-native** | Sync to `~/.cursor/` (skills, rules, hooks, router) |
| **Operational skills** | EF migrations, fix-build, test-coverage, repo docs, backlog refine/breakdown, message-consumer scaffold (Git-only) |
| **Caveman Mode** | Optional response compression mode to reduce token usage and speed up interactions |

## Quick start

1. Clone this repo.
2. Follow **[docs/INSTALL.md §2](docs/INSTALL.md#2-deploy-to-cursor)** (full deploy steps) or run from repo root:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
   .\scripts\validation\validate-all.ps1
   ```

   Or: `.\scripts\toolkit.ps1`

3. For **daily skill usage**, open **[docs/guides/README.md](docs/guides/README.md)** (decision tree + guides).
4. In any project chat: `/sdd-spec` -> `/sdd-plan` -> `/sdd-develop - <plan-path> - Step N` (repo or global storage). See [SDD workflow guide](docs/guides/01-sdd-workflow.md) for details.

Re-run sync after pulling toolkit updates (idempotent).

## Documentation

| Doc | Content |
|-----|---------|
| [docs/guides/README.md](docs/guides/README.md) | **Daily usage** - decision tree, skill manuals (guides 01-10) |
| [docs/INSTALL.md](docs/INSTALL.md) | Install, sync, short usage index |
| [docs/README.md](docs/README.md) | Documentation index |
| [docs/HOOKS.md](docs/HOOKS.md) | Optional hooks (behavior, limits) |
| [docs/MAINTAINER_GUIDE.md](docs/MAINTAINER_GUIDE.md) | Repository layout and maintainer checklist |
| [docs/SKILLS.md](docs/SKILLS.md) | Canonical skill catalog (34 skills) |
| [docs/impeccable-integration.md](docs/impeccable-integration.md) | Impeccable design -> DESIGN-BRIEF -> stack developer handoff |
| [docs/blip-plugin-integration.md](docs/blip-plugin-integration.md) | Blip plugin scaffold -> SDD -> `react-developer` + `blip-guidelines/` |
| [docs/architecture.md](docs/architecture.md) | Deployment and enforcement model |
| [docs/shared-guidelines.md](docs/shared-guidelines.md) | Index of `_shared/` packs |
| [docs/ENFORCEMENT.md](docs/ENFORCEMENT.md) | Rules, hooks, session gates |
| [docs/SYNC_POLICY.md](docs/SYNC_POLICY.md) | Cross-toolkit sync with antigravity-dev-toolkit |
| [AGENTS.md](AGENTS.md) | Agent router (synced to `~/.cursor/`) |

## Repository layout

```
cursor-dev-toolkit/
├── AGENTS.md
├── README.md
├── docs/                  # INSTALL, guides/, HOOKS, MAINTAINER_GUIDE, TOKEN_BUDGET
│   └── guides/            # User skill manuals (English, versioned)
├── rules/                 # -> ~/.cursor/rules/*.mdc
│   ├── caveman-mode.md    # Global response compression trigger
│   └── …
├── hooks/                 # -> ~/.cursor/hooks/ + merge hooks.json
├── scripts/               # sync, toolkit, uninstall; validation/, maintainers/, _lib/
└── skills/                # -> ~/.cursor/skills/
    ├── sdd-spec/
    ├── sdd-plan/
    ├── sdd-develop/
    ├── orchestrate-analyze/
    ├── orchestrate-deliver/
    ├── orchestrate-develop/
    ├── code-review/
    ├── commit/
    ├── developer/         # Stack router
    ├── impeccable/        # Frontend design (shape, audit, polish)
    ├── blip-plugin-developer/  # Blip React extension scaffold + handoff
    ├── dotnet-developer/
    ├── blazor-developer/
    ├── react-developer/, angular-developer/, vue-developer/
    ├── electron-developer/, javascript-developer/, python-developer/
    ├── add-migrations/
    ├── fix-build/
    ├── test-coverage/
    ├── document-plan/
    ├── document-implement/
    ├── refine-backlog-item/
    ├── breakdown-tasks/
    ├── create-message-consumer/
    └── _shared/
        ├── backlog-item-types/
        ├── dotnet-guidelines/
        ├── blip-guidelines/   # Blip plugin iframe, BDS, auth, API, deploy
        ├── caveman/       # Shared Caveman Mode guideline file
        └── …
```

## Skills (after sync)

| Skill | Invoke | Use for |
|-------|--------|---------|
| `sdd-spec` | `/sdd-spec` | PRD from a feature request |
| `sdd-plan` | `/sdd-plan` | Baby-step PLAN from PRD |
| `sdd-develop` | `/sdd-develop` | One PLAN step per session |
| `orchestrate-analyze` | `/orchestrate-analyze` | Forma C O1 - multi-story analyze / backlog |
| `orchestrate-deliver` | `/orchestrate-deliver` | Forma C O2 - PRD/PLAN per story |
| `orchestrate-develop` | `/orchestrate-develop` | Forma C O3 - one PLAN step per subagent |
| `code-review` | `/code-review` | Review diff or branch vs PRD/PLAN |
| `commit` | `/commit` | Conventional commit and push |
| `developer` | `/developer` | Stack router for small tasks |
| `impeccable` | `/impeccable` | UI design; shape -> DESIGN-BRIEF |
| `blip-plugin-developer` | `/blip-plugin-developer` | New Blip React plugin scaffold |
| `dotnet-developer` | `/dotnet-developer` | Small .NET work without full SDD |
| `blazor-developer` | `/blazor-developer` | Small Blazor UI work |
| `react-developer` | `/react-developer` | Small React work |
| `angular-developer` | `/angular-developer` | Small Angular work |
| `vue-developer` | `/vue-developer` | Small Vue 3 work |
| `electron-developer` | `/electron-developer` | Small Electron desktop work |
| `javascript-developer` | `/javascript-developer` | Small Node/JS work |
| `python-developer` | `/python-developer` | Small Python work |
| `add-migrations` | `/add-migrations` | EF Core migration in the open repo |
| `fix-build` | `/fix-build` | Fix build/test failures (local; optional `gh`) |
| `test-coverage` | `/test-coverage` | .NET coverage report (Coverlet; SonarQube-aligned metrics) |
| `document-plan` | `/document-plan` | Plan repo documentation (RAG-oriented) |
| `document-implement` | `/document-implement` | Execute one doc plan step |
| `refine-backlog-item` | `/refine-backlog-item` | Refine bug/story + quality scorecard |
| `breakdown-tasks` | `/breakdown-tasks` | Implementation task checklist (local markdown) |
| `create-message-consumer` | `/create-message-consumer` | Scaffold message consumer (scaffold) |

Optional flows: Forma C (`orchestrate-analyze` -> `orchestrate-deliver` -> `orchestrate-develop` \| `sdd-develop`); repo docs (`document-plan` -> `document-implement`); backlog (`refine-backlog-item` -> `breakdown-tasks` -> Forma A or C); frontend design (`impeccable shape` -> `DESIGN-BRIEF.md` -> `*-developer`); Blip plugin (`blip-plugin-developer` -> SDD -> `react-developer`). See [AGENTS.md](AGENTS.md).

Details and shared assets: [docs/MAINTAINER_GUIDE.md](docs/MAINTAINER_GUIDE.md).

## Conventions

| Area | Rule |
|------|------|
| Skill names | English, kebab-case (`sdd-spec`, `sdd-plan`, `orchestrate-analyze`) |
| SDD agent artifacts (PRD, PLAN `.md`) | Brazilian Portuguese (pt-BR) - `rules/sdd-artifact-language-pt-br.md` |
| Production code & tests | English; tests `Should_<Result>_When_<Condition>` |
| Project docs (`docs/`, README deliverables) | Ask pt-BR or English in skill |
| Test stack | xUnit + Moq + FluentAssertions |
| User chat replies | Brazilian Portuguese (pt-BR) - `rules/user-language-pt-br.md` |
| SDD Storage Mode | Local `repository` (in-repo) or `global` (centralized `~/.cursor/sdd/`) resolved via `manifest.json` |

## Rules (after sync)

| Source | Installed | When |
|--------|-----------|------|
| `rules/ai-stealth.md` | `~/.cursor/rules/ai-stealth.mdc` | No AI authorship traces |
| `rules/guardrails.md` | `~/.cursor/rules/guardrails.mdc` | Core gates |
| `rules/conventional-commits.md` | `~/.cursor/rules/conventional-commits.mdc` | Every commit |
| `rules/branch-validation.md` | `~/.cursor/rules/branch-validation.mdc` | Before commit/push |
| `rules/context-management.md` | `~/.cursor/rules/context-management.mdc` | Multi-step SDD |
| `rules/user-language-pt-br.md` | `~/.cursor/rules/user-language-pt-br.mdc` | Always pt-BR in chat |
| `rules/sdd-artifact-language-pt-br.md` | `~/.cursor/rules/sdd-artifact-language-pt-br.mdc` | PRD/PLAN `.md` in pt-BR; code always English |
| `rules/caveman-mode.md` | `~/.cursor/rules/caveman-mode.mdc` | Compression of chat responses when enabled |

Branches: `feature/<slug>` or `feat/<id>` only - not `main`, `master`, or `develop`.

## Caveman Mode (Response Compression)

Caveman Mode is an optional feature designed to reduce output token consumption by stripping away polite filler text and verbose progress narration, while fully protecting technical facts, code blocks, and confirmation gates.

- **Persisted State**: Configured in `~/.cursor/sdd/preferences.json` under `"caveman_mode"`.
- **In-Session Toggles**: 
  - Send `caveman on` in chat to enable response compression.
  - Send `caveman off` in chat to disable response compression.
- **Participation Levels**:
  - **NEVER**: `commit` (kept verbose for safety).
  - **LITE**: `sdd-spec`, `sdd-plan` (compresses headers/preambles, but keeps questions and drafts intact).
  - **FULL**: `code-review`, `developer`, `fix-build`, `test-coverage`, `sdd-develop` (compresses all prose to telegraphic bullet points).

For a complete explanation, see [docs/guides/07-caveman-mode.md](docs/guides/07-caveman-mode.md).

## License

Personal use.
