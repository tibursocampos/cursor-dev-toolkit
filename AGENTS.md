# Cursor agent router — cursor-dev-toolkit

Lean router for agents when this toolkit is installed under `~/.cursor/`. Pointers only — do not paste guideline bodies here.

## Language

| Context | Rule |
|---------|------|
| SDD agent artifacts (`PRD/*.md`, `PLAN/PLAN_*.md`, global `~/.cursor/sdd/...`) | Brazilian Portuguese (pt-BR) — `sdd-artifact-language-pt-br.mdc`; English only if user requests in skill invocation |
| Source code, tests, commits, identifiers in artifacts | English always |
| Project docs (`docs/`, README deliverables) | Ask pt-BR or English in skill before writing |
| User-facing chat replies | Brazilian Portuguese (pt-BR) — `user-language-pt-br.mdc` |

## Workflows

### SDD — Spec Driven Development

Use for medium/high complexity: migrations, multiple components, cross-cutting design, or unclear scope.

```
spec → plan → implement (one PLAN step per session)
```

| Skill | Invoke | Typical output |
|-------|--------|----------------|
| spec | "use skill spec" | `PRD/` or `docs/PRD/` **or** `~/.cursor/sdd/<repo-id>/PRD/` |
| plan | "use skill plan" | `PLAN/PLAN_XXX.md` **or** `~/.cursor/sdd/<repo-id>/PLAN/` |
| implement | "use skill implement" | Code + PLAN step checkbox (same path as handoff) |

**Checkpoint:** one `implement` session = one PLAN step. Start a new session for the next step.

### Shortcut — small .NET work

For isolated fixes, small refactors, or low complexity (single area, no PRD needed):

```
dotnet-developer
```

Invoke with "use skill dotnet-developer". Loads `dotnet-guidelines` on demand; skip full SDD when unnecessary.

## Rules (load on demand)

After `scripts/sync-cursor.ps1`, rules live as `.mdc` under `~/.cursor/rules/`:

| When | Path |
|------|------|
| Every git commit | `~/.cursor/rules/conventional-commits.mdc` |
| Before commit/push (branch name) | `~/.cursor/rules/branch-validation.mdc` |
| Multi-step skills / context pressure | `~/.cursor/rules/context-management.mdc` |
| SDD agent PRD/PLAN `.md` language | `~/.cursor/rules/sdd-artifact-language-pt-br.mdc` |
| User-facing reply language | `~/.cursor/rules/user-language-pt-br.mdc` |

Rules override conflicting inline text in skills.

## Hooks (optional)

After sync, `~/.cursor/hooks.json` may register context/PLAN helpers. See `docs/HOOKS.md`. Install: `docs/INSTALL.md`. Hooks do **not** select models.

## Shared guidelines (load on demand)

**Do not** read these preemptively. Skills load the minimum set when invoked.

| When | Path |
|------|------|
| .NET implementation / Clean Architecture | `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md` |
| C# style and tests (xUnit, Moq, FluentAssertions; `Should_<Result>_When_<Condition>`) | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` |
| Pre-PR / pre-push checklist | `~/.cursor/skills/_shared/dotnet-guidelines/checklist.md` |
| Git flow orchestration | `~/.cursor/skills/_shared/developer-common/GUIDE.md` |
| SOLID, DRY, KISS, YAGNI, encapsulation | `~/.cursor/skills/_shared/code-guidelines/principles/` (single file as needed) |
| Commit / branch / PR comment format | `~/.cursor/skills/_shared/format-validators/` |

### Explicit exclusions (token budget)

- **Never preload** `~/.cursor/skills/_shared/code-guidelines/languages/**` or glob the entire `code-guidelines/` tree.
- **Never preload** `dotnet-guidelines/` until you are about to write or review .NET code.
- **Not in this toolkit:** corporate pipeline layouts, work-item trackers, static-analysis fix workflows.

Project-specific docs: prefer `docs/` in the **working repository** (the repo you are building), not files in `cursor-dev-toolkit`.

## Skills catalog

Installed under `~/.cursor/skills/` after sync:

| Skill | Use for |
|-------|---------|
| spec | PRD from a feature request |
| plan | Baby-step PLAN from PRD |
| implement | Execute one PLAN step |
| code-review | Review diff or branch; resolves PRD/PLAN like spec (`STORAGE.md`, repo + global) |
| commit | Conventional commit and push |
| dotnet-developer | Small .NET task without full SDD |

## Loading principles

1. **Lazy-load only** — each skill reads what it needs when invoked.
2. **Guidelines win conflicts** — if a skill disagrees with `dotnet-guidelines`, follow the guideline file.
3. **One PLAN step per session** — persist PLAN state; continue in a new chat for the next step.
4. **Token discipline** — see `docs/TOKEN_BUDGET.md` in the toolkit repo.

## Editing this toolkit repo

Do not commit user-specific paths (`C:\Users\...`, `/home/<user>/...`), tokens, or API keys. Use `$HOME`, `~/.cursor/`, and placeholders such as `<TOKEN>`.

---

Maintainer guide: `docs/MAINTAINER_GUIDE.md` · Install: `docs/INSTALL.md`
