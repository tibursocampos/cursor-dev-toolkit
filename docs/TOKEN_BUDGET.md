# Token budget — cursor-dev-toolkit

Guidelines for building and **using** this toolkit without blowing context or cost. One PLAN step = one agent session.

> **MVP build (PLAN_001):** completed (14/14). This doc remains useful when extending the toolkit (v1.1 `languages/dotnet`, etc.).

## Source material sizes

| Package | ~Tokens | MVP? |
|---------|---------|------|
| `dotnet-guidelines` (3 files) | 6.6k | Yes — core |
| `developer-common` (Git-only) | ~12k | Yes |
| Skills `spec` + `plan` + `implement` | 12–15k total | Yes |
| `code-review` + `commit` + `dotnet-developer` | ~8k | Yes |
| `rules/` | 4.6k | Yes |
| `format-validators` | 4k | Yes |
| `code-guidelines/principles` | 6k | Yes |
| `code-guidelines/languages/dotnet` | 29k | v1.1 optional |
| Full `code-guidelines` (Angular, Cypress, etc.) | 93k | v2 — defer |

**Versioned repo (MVP markdown):** ~45–55k tokens; ~75k if including dotnet language guidelines.

## One-time build cost (optimized)

| Approach | Input tokens | Output tokens | USD (order of magnitude) | Human time |
|----------|--------------|---------------|--------------------------|------------|
| **Optimized** (PLAN_001) | 450k–700k | 150k–250k | $3–15 (mid) / $25–50 (premium) | 8–14h |
| **Naïve** (read full `_shared`, full skills) | 2M–5M+ | — | $15–80+ | 20–40h |

## Per-step budgets (PLAN_001)

| Step | Token budget (in) | Time |
|------|-------------------|------|
| 1 Scaffold | ~15k in / ~8k out | 30 min |
| 2 Maintainer guide + structure | ~20k | 45 min |
| 3 dotnet-guidelines | ~35k | 2h |
| 4 AGENTS.md | ~25k | 1h |
| 5 Rules | ~20k | 1h |
| 6 spec | ~40k | 1.5h |
| 7 plan | ~40k | 1.5h |
| 8 implement | ~45k | 2h |
| 9 developer-common | ~30k | 1.5h |
| 10 commit, code-review, dotnet-developer | ~50k | 2h |
| 11 principles + validators | ~25k | 1h |
| 12 QA | ~30k | 1h |
| 13 hooks (opt) | ~25k | 1.5h |
| 14 sync (opt) | ~20k | 1h |

**Recommended sessions:** 12 (steps 1–12) + 0–2 optional = **12–14 conversations**.

## Golden rules (construction)

1. **One step = one session** — baby step per PLAN; new session after checkpoint.
2. **Never `@` entire `_shared`** — only files listed in the current step.
3. **Trim integrations first** — remove work-item/MCP sections; keep English prose lean.
4. **Split large skills** — `SKILL.md` ≤ 150 lines + `reference.md` (see [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md)).
5. **Mechanical copy** — small stable files via script/`cp`; agent reviews diff only.
6. **Batch related edits** — e.g. all `dotnet-guidelines` in one session, not mixed with skills.
7. **code-guidelines by phase** — v1 = `principles/` only; v1.1 = `languages/dotnet/`.
8. **Lean router** — `AGENTS.md` < 150 lines; table of paths, no pasted guidelines.
9. **Search before Read** — grep for scope; read only relevant chunks.
10. **Cheap model for markdown** — fast tier for trim/translate; premium for architecture decisions only.

## Recurring use (daily)

With lazy-load in `AGENTS.md`:

| Work type | Typical fixed context |
|-----------|----------------------|
| Small .NET feature | 15–25k |
| SDD spec | 10–18k |
| SDD implement (one step) | 12–20k |
| Code review | 10–15k |

Without lazy-load: **+50–90k** per prompt → roughly 3–5× monthly cost.

## What the agent must not do when extending

- Load `spec` + `implement` reference bodies in the same session without need.
- Import entire `code-guidelines` (~93k tokens).
- Re-read full repo tree every step — use [MAINTAINER_GUIDE.md](MAINTAINER_GUIDE.md) for layout.
