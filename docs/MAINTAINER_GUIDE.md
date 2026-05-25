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
├── PRD/                               # Example SDD artifact (consumer repos use same layout)
├── PLAN/
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
    └── _shared/
        ├── sdd-artifacts/
        │   └── STORAGE.md              # PRD/PLAN repo vs ~/.cursor/sdd/
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

Shared assets live under `~/.cursor/skills/_shared/` (`dotnet-guidelines`, `developer-common`, `code-guidelines`, `format-validators`).

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

- Work-item tracker APIs or MCP linking
- Fixed corporate pipeline layouts
- Mandatory third-party static-analysis fix workflows
- Automatic model selection via hooks

Consumer projects may use their own CI and trackers; skills stay **Git-only** unless the working repo documents otherwise.

## Related docs

| Document | Purpose |
|----------|---------|
| [INSTALL.md](INSTALL.md) | End-user install and SDD usage |
| [HOOKS.md](HOOKS.md) | Optional hooks |
| [TOKEN_BUDGET.md](TOKEN_BUDGET.md) | Token discipline when extending content |
| [../AGENTS.md](../AGENTS.md) | Agent router |
| [../PLAN/PLAN_001_cursor_dev_toolkit.md](../PLAN/PLAN_001_cursor_dev_toolkit.md) | Example SDD plan (toolkit bootstrap) |
