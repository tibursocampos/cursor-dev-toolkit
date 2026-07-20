# Portability contract

What is **Cursor-specific** in this toolkit versus what is **reusable** if you ever port ideas to another agent/IDE.

## Runtime (scripts)

| Piece | Contract |
|-------|----------|
| Canonical language | **PowerShell 7+** (`pwsh`) on Windows, macOS, and Linux |
| `.sh` wrappers | Thin launchers that `exec pwsh` — not a second implementation |
| Validation | `scripts/validation/*.ps1` exit codes; CI runs the same scripts |

Scripts should resolve the user home in a cross-platform way (`$HOME` / `[Environment]::GetFolderPath('UserProfile')`), not assume Windows-only paths.

## Cursor-specific (does not migrate automatically)

| Surface | Examples |
|---------|----------|
| Install root | `~/.cursor/skills`, `~/.cursor/rules`, `~/.cursor/hooks`, `~/.cursor/AGENTS.md` |
| Invoke style | Slash commands (`/sdd-spec`, `/orchestrate-analyze`) |
| Rules format | `.mdc` under `rules/` synced to Cursor rules |
| Hooks | `hooks.json` + PowerShell hooks under `~/.cursor/hooks/` (Windows-oriented runner today) |
| Subagents | Cursor `Task` tool in Forma C / multi-angle review |
| Session state | `~/.cursor/sdd/sessions/`, `hooks-state/` |

If Cursor changes skill/rule packaging, **only this surface** needs an adapter. Rebuild sync + invoke docs; keep the reusable core below.

## Reusable core (portable content)

| Surface | Examples |
|---------|----------|
| Pipeline contract | `skills/_shared/sdd-artifacts/PIPELINE.md`, `STORAGE.md`, `SESSION.md`, `MEMORY-BANK.md` |
| Templates | `skills/_shared/templates/features/`, memory-bank templates |
| Guidelines | `_shared/dotnet-guidelines`, `git-guidelines`, `frontend-*`, `blip-guidelines`, etc. |
| Skill bodies | Process steps, gates, must-not rules (rename invoke syntax per IDE) |
| Forma model | A / B / C semantics: O2 reuses spec/plan; O3 reuses develop |
| Validation ideas | Skill contracts, fixtures, docs consistency checks |

## Git / PR policy (tool-agnostic)

- Branch: `feature/<slug>` or `feat/<id>` only for commits
- Integration target: `develop`; release from `develop` → `main`/`master`
- **No GitHub CLI** in skills — `git` locally; open PRs in the **GitHub web UI**

## What this doc is not

It is **not** an abstraction layer or multi-IDE runtime. It is a map so a future port knows what to keep versus what to rewrite.
