# Maintainer guide — cursor-dev-toolkit

Reference for repository layout, deploy, and conventions when extending this toolkit.

| Field | Value |
|-------|--------|
| **Install target** | `~/.cursor/` via `scripts/sync-cursor.ps1` |
| **Install guide** | [INSTALL.md](INSTALL.md) |
| **Toolkit paths** | `skills/`, `rules/`, `hooks/`, `scripts/`, `AGENTS.md`, `docs/` |

## Repository layout

Deployed to `~/.cursor/` by `scripts/sync-cursor.ps1`. See [INSTALL.md](INSTALL.md) for usage.

```
cursor-dev-toolkit/
├── AGENTS.md                          # Router (→ ~/.cursor/AGENTS.md)
├── README.md
├── docs/
│   ├── README.md
│   ├── INSTALL.md
│   ├── MAINTAINER_GUIDE.md            # This file
│   ├── HOOKS.md
│   └── TOKEN_BUDGET.md
├── rules/                             # → ~/.cursor/rules/*.mdc
│   ├── conventional-commits.md
│   ├── branch-validation.md
│   ├── context-management.md
│   ├── user-language-pt-br.md
│   └── sdd-artifact-language-pt-br.md
├── hooks/                             # → ~/.cursor/hooks/ + merge hooks.json
│   ├── hooks.json
│   ├── context-before-prompt.ps1
│   ├── plan-after-edit.ps1
│   ├── context-pre-compact.ps1
│   └── _hook-common.ps1
├── scripts/
│   └── sync-cursor.ps1
└── skills/                            # → ~/.cursor/skills/
    ├── spec/                          # + reference.md
    ├── plan/                          # + reference.md
    ├── implement/                     # + reference.md
    ├── code-review/                   # + reference.md
    ├── commit/
    ├── dotnet-developer/
    ├── add-migrations/
    ├── fix-build/
    ├── test-coverage/                   # + reference.md
    ├── plan-repo-docs/
    ├── document-repo/
    ├── refine-backlog-item/
    ├── breakdown-tasks/
    ├── create-message-consumer/
    └── _shared/
        ├── backlog-item-types/         # bug, user-story, technical-story templates
        ├── sdd-artifacts/
        │   ├── STORAGE.md              # PRD/PLAN repo vs ~/.cursor/sdd/
        │   └── PIPELINE.md             # Order, modes, confirm-before-write, dialogs
        ├── dotnet-guidelines/
        ├── developer-common/
        ├── code-guidelines/
        │   ├── README.md
        │   └── principles/
        └── format-validators/
```

## Skills catalog

| Skill | Installed path | Typical output |
|-------|----------------|----------------|
| `spec` | `~/.cursor/skills/spec/` | `PRD/` or `docs/PRD/` or `~/.cursor/sdd/<repo-id>/PRD/` |
| `plan` | `~/.cursor/skills/plan/` | `PLAN/PLAN_XXX.md` or global PLAN under `~/.cursor/sdd/` |
| `implement` | `~/.cursor/skills/implement/` | Code + PLAN step checkbox (handoff path) |
| `code-review` | `~/.cursor/skills/code-review/` | Structured review report |
| `commit` | `~/.cursor/skills/commit/` | Conventional commit + optional push |
| `dotnet-developer` | `~/.cursor/skills/dotnet-developer/` | Small .NET changes without full SDD |
| `add-migrations` | `~/.cursor/skills/add-migrations/` | EF Core migration in consumer .NET repo |
| `fix-build` | `~/.cursor/skills/fix-build/` | Build/test diagnosis (Git-only; optional `gh`) |
| `test-coverage` | `~/.cursor/skills/test-coverage/` | .NET coverage report (Coverlet; SonarQube-aligned metrics) |
| `plan-repo-docs` | `~/.cursor/skills/plan-repo-docs/` | Documentation plan for consumer repo |
| `document-repo` | `~/.cursor/skills/document-repo/` | One step of consumer doc plan |
| `refine-backlog-item` | `~/.cursor/skills/refine-backlog-item/` | Local backlog markdown + scorecard |
| `breakdown-tasks` | `~/.cursor/skills/breakdown-tasks/` | `docs/implementation-tasks/` checklist |
| `create-message-consumer` | `~/.cursor/skills/create-message-consumer/` | Message consumer scaffold (bus-agnostic) |

Shared assets: `dotnet-guidelines`, `developer-common`, `code-guidelines`, `format-validators`, `backlog-item-types/` (for `refine-backlog-item` only).

## Deploy

From repo root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
```

Preview: add `-DryRun`. Re-run after pulling toolkit updates (idempotent).

## Checklist: new skill or rule

1. **English** — skill names kebab-case; SKILL.md and shared guidelines in English. **SDD agent PRD/PLAN `.md`** default pt-BR (`sdd-artifact-language-pt-br.md`). **Code** always English.
2. **Split large skills** — `SKILL.md` ≤ **150 lines**; overflow in `reference.md`.
3. **Lazy-load** — router (`AGENTS.md`) lists paths only; do not paste full guideline bodies.
4. **Line count** — from repo root:

   ```powershell
   Get-ChildItem skills -Directory | Where-Object { $_.Name -ne '_shared' } | ForEach-Object {
     $f = Join-Path $_.FullName 'SKILL.md'
     if (Test-Path $f) { "$($_.Name): $((Get-Content $f).Count) lines" }
   }
   ```

5. **Sync** — run `sync-cursor.ps1` and verify under `~/.cursor/`.

## Out of scope for this toolkit

Do not add or document as built-in:

- **Azure DevOps** (or similar) work-item REST/PATCH, PAT scripts, MCP `wit_*`, custom field names (`Custom.Standard_*`), mandatory `TechAI` tags
- Skills from ai-prompts not ported: `setup`, `fix-pr-comments` (ADO-coupled), `fix-sonar-issues`, `cypress-developer`, `angular-upgrade`
- Fixed corporate pipeline layouts or agent pool documentation
- Mandatory third-party static-analysis fix workflows
- Automatic model selection via hooks
- Embedded consumer code templates copied from internal monorepos (skills discover patterns in the **target** repo)

When porting from ai-prompts: grep gate — no `dev.azure.com`, internal org/product names, or ADO-specific guardrails in new skill bodies.

Consumer projects may use their own CI and trackers; toolkit skills stay **Git-only** unless the working repo documents otherwise.

## Related docs

| Document | Purpose |
|----------|---------|
| [INSTALL.md](INSTALL.md) | End-user install and SDD usage |
| [HOOKS.md](HOOKS.md) | Optional hooks |
| [TOKEN_BUDGET.md](TOKEN_BUDGET.md) | Token discipline when extending content |
| [../AGENTS.md](../AGENTS.md) | Agent router |
| [../skills/_shared/sdd-artifacts/STORAGE.md](../skills/_shared/sdd-artifacts/STORAGE.md) | SDD PRD/PLAN storage (consumer repos; local/gitignored) |
| [../skills/_shared/sdd-artifacts/PIPELINE.md](../skills/_shared/sdd-artifacts/PIPELINE.md) | SDD pipeline guards (spec/plan/implement) |
| [../rules/sdd-pipeline-guards.md](../rules/sdd-pipeline-guards.md) | Always-on SDD pipeline rule (synced as `.mdc`) |
