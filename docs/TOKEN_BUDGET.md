# Token budget — cursor-dev-toolkit

Guidelines for **using** and **extending** this toolkit without blowing context or cost. One PLAN step = one agent session.

## Bundled content sizes

| Package | ~Tokens | Default sync |
|---------|---------|--------------|
| `dotnet-guidelines` (3 files) | 6.6k | Yes — core |
| `developer-common` (Git-only) | ~12k | Yes |
| Skills `spec` + `plan` + `implement` | 12–15k total | Yes |
| `code-review` + `commit` + `dotnet-developer` | ~8k | Yes |
| Ported operational skills (7 × `SKILL.md` + `reference.md`) | ~18–22k | Yes — **lazy on invoke** |
| `_shared/backlog-item-types/` (3 templates) | ~3k | Yes — `refine-backlog-item` only |
| `rules/` | 4.6k | Yes |
| `format-validators` | 4k | Yes |
| `code-guidelines/principles` | 6k | Yes |
| `code-guidelines/languages/dotnet` | ~29k (deferred) | Not in repo — use `dotnet-guidelines/` per MVP |
| Full `code-guidelines` (Angular, Cypress, etc.) | 93k | Out of toolkit — defer |

**Typical toolkit footprint (markdown in repo):** ~45–55k tokens for the default SDD bundle; **~65–75k** including all ported operational skills on disk (still lazy-loaded per invocation). ~75–90k if you also load `languages/dotnet` in the same session.

## Golden rules (extension and maintenance)

1. **One step = one session** — baby step per PLAN; new session after checkpoint.
2. **Never `@` entire `_shared`** — only files listed for the current task.
3. **Trim integrations first** — remove work-item/MCP sections; keep English prose lean.
4. **Split large skills** — `SKILL.md` ≤ 150 lines + `reference.md` (see [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md)).
5. **Mechanical copy** — small stable files via script/`cp`; agent reviews diff only.
6. **Batch related edits** — e.g. all `dotnet-guidelines` in one session, not mixed with skills.
7. **code-guidelines in layers** — default: `principles/` only; add `languages/dotnet/` only when needed.
8. **Lean router** — `AGENTS.md` < 150 lines; table of paths, no pasted guidelines.
9. **Search before Read** — grep for scope; read only relevant chunks.
10. **Match model to task** — fast tier for trim/docs; premium for architecture decisions only.

## Recurring use (daily)

With lazy-load in `AGENTS.md`:

| Work type | Typical fixed context |
|-----------|----------------------|
| Small .NET feature | 15–25k |
| SDD spec | 10–18k |
| SDD implement (one step) | 12–20k |
| Code review | 10–15k |
| `fix-build` / `add-migrations` | 8–15k |
| `refine-backlog-item` + `breakdown-tasks` | 10–18k |
| `plan-repo-docs` / `document-repo` (one step) | 12–20k |
| `create-message-consumer` (scaffold) | 10–16k |

Without lazy-load: **+50–90k** per prompt → roughly 3–5× monthly cost.

## What the agent must not do when extending

- Load `spec` + `implement` reference bodies in the same session without need.
- Import entire `code-guidelines` (~93k tokens).
- Re-read full repo tree every step — use [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md) for layout.
