# PLAN 001 — cursor-dev-toolkit (MVP build)

| Field | Value |
|-------|--------|
| **PRD** | `PRD/001_cursor_dev_toolkit.md` |
| **Repository** | `cursor-dev-toolkit` |
| **Complexity** | Medium |
| **Total steps** | 14 (MVP) + 2 optional |
| **Progress** | 14/14 |

```
[🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢] 100% (14/14)
```

## Objectives

- [x] O1: Publishable personal toolkit repo with EN guidelines
- [x] O2: Installable to `~/.cursor/` via sync script
- [x] O3: SDD workflow operational (spec → plan → implement)
- [x] O4: Token-efficient structure (split skills, lazy-load)

## Target tree (deliverables)

```
cursor-dev-toolkit/
├── AGENTS.md
├── README.md
├── PRD/001_cursor_dev_toolkit.md
├── PLAN/PLAN_001_cursor_dev_toolkit.md
├── docs/MAINTAINER_GUIDE.md
├── docs/TOKEN_BUDGET.md
├── rules/*.md
├── scripts/sync-cursor.ps1
└── skills/
    ├── spec/SKILL.md, reference.md
    ├── plan/SKILL.md, reference.md
    ├── implement/SKILL.md, reference.md
    ├── code-review/SKILL.md
    ├── commit/SKILL.md
    ├── dotnet-developer/SKILL.md
    └── _shared/
        ├── dotnet-guidelines/
        ├── developer-common/
        ├── code-guidelines/principles/
        └── format-validators/
```

## Validation strategy

- [x] Each `skills/*/SKILL.md` ≤ 150 lines (ETAPA 2, 12)
- [x] Each skill has valid YAML frontmatter (`name`, `description`) (ETAPA 12)
- [ ] Manual: invoke "use skill spec" in Cursor on a sample repo
- [x] `sync-cursor.ps1` copies to `~/.cursor/` without overwriting unrelated settings

---

## Implementation steps

### ✅ ETAPA 1: Scaffold repo + PRD/PLAN artifacts

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** none | **Token budget:** ~15k in / ~8k out | **Time:** 30 min

**Deliverables:**

- [x] Repo root: `README.md`, `.gitignore`
- [x] `docs/TOKEN_BUDGET.md`
- [x] `PRD/001_cursor_dev_toolkit.md`
- [x] `PLAN/PLAN_001_cursor_dev_toolkit.md` (this file)
- [x] Placeholder dirs: `skills/`, `rules/`, `scripts/`

**Acceptance:** Tree exists; PLAN tracks 14 steps. ✅

---

### ✅ ETAPA 2: Maintainer guide + structure QA

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** 1 | **Token budget:** ~20k | **Time:** 45 min

- [x] `docs/MAINTAINER_GUIDE.md` — repository layout and extension checklist
- [x] Skill line-count convention documented (≤ 150 lines per `SKILL.md`)

**Acceptance:** Maintainer guide complete; structure documented. ✅

---

### ✅ ETAPA 3: `dotnet-guidelines` — EN + xUnit/Moq

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** 2 | **Token budget:** ~35k | **Time:** 2h

**Files:** `clean-architecture.md`, `csharp-patterns.md`, `checklist.md` only.

- [x] Create `dotnet-guidelines` (3 files)
- [x] Neutral branding; English identifiers in examples
- [x] Test stack: xUnit, Moq, FluentAssertions; `Should_<Result>_When_<Condition>`
- [x] No pipeline-guidelines in MVP

**Acceptance:** No PT prose; xUnit/Moq documented; guidelines EN. ✅

---

### ✅ ETAPA 4: `AGENTS.md` router (EN) + lazy-load table

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** 3 | **Token budget:** ~25k | **Time:** 1h

- [x] SDD: spec → plan → implement; shortcut dotnet-developer
- [x] Global rule: production code English; reply PT-BR when user writes PT
- [x] Pointer table to `~/.cursor/skills/_shared/...` paths
- [x] Explicit: do not preload `code-guidelines` glob

**Acceptance:** < 150 lines; no work-item tracker references. ✅

---

### ✅ ETAPA 5: Rules → `.mdc` sources

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** 4 | **Token budget:** ~20k | **Time:** 1h

- [x] `rules/conventional-commits.md` — EN, Conventional Commits, Cursor frontmatter
- [x] `rules/branch-validation.md` — `feature/<slug>` or `feat/<id>`
- [x] `rules/context-management.md` — EN; no external JSONL / `check-context.ps1`
- [x] README documents sync to `~/.cursor/rules/*.mdc` (ETAPA 14)

**Acceptance:** 3 rule files; branch pattern `feature/<slug>` or `feat/<id>`. ✅

---

### ✅ ETAPA 6: Skill `spec` — trim, EN, Cursor paths

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** 4 | **Token budget:** ~40k | **Time:** 1.5h

- [x] Trim work-item/MCP/repo-mappings sections
- [x] `SKILL.md` < 120 lines + `reference.md` for PRD template
- [x] `name: spec`; triggers in description

**Acceptance:** PRD output path `PRD/` or `docs/PRD/`. ✅

---

### ✅ ETAPA 7: Skill `plan` — trim, EN, PLAN template

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** 6 | **Token budget:** ~40k | **Time:** 1.5h

- [x] Baby-step template EN
- [x] Remove external tracker exploration steps
- [x] `SKILL.md` (< 120 lines) + `reference.md`

**Acceptance:** Produces `PLAN/PLAN_XXX.md` format (EN). ✅

---

### ✅ ETAPA 8: Skill `implement` — trim, EN, Git-only

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** 7 | **Token budget:** ~45k | **Time:** 2h

- [x] Git-only flow; PLAN step update protocol
- [x] Reference `dotnet-guidelines` lazy-load
- [x] `SKILL.md` + `reference.md`

**Acceptance:** One PLAN step per session documented; checkpoint rule cited. ✅

---

### ✅ ETAPA 9: `developer-common` Git-only steps

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** 4 | **Token budget:** ~30k | **Time:** 1.5h

- [x] Keep: step-0, step-0.5, step-3, step-3.5, step-4, step-7 (translate EN)
- [x] Omitted: work-item, estimation, wiki, PR-integration steps
- [x] Update `GUIDE.md` orchestration diagram
- [x] `templates/todo-list.md` (Git-only)
- [x] Document `skills/*/SKILL.md` max 150 lines

**Acceptance:** GUIDE lists only Git flow; all EN. ✅

---

### ✅ ETAPA 10: Skills `commit`, `code-review`, `dotnet-developer`

**Status:** Concluída | **Completed:** 2026-05-21 | **Deps:** 3, 9 | **Token budget:** ~50k | **Time:** 2h

- [x] `skills/commit/SKILL.md` — Git-only Conventional Commits; `branch-validation` + `step-4`
- [x] `skills/code-review/SKILL.md` + `reference.md` — PRD/PLAN traceability; `dotnet-guidelines`
- [x] `skills/dotnet-developer/SKILL.md` — shortcut .NET path; SDD escalation

**Acceptance:** Each skill < 150 lines or split reference. ✅

---

### ✅ ETAPA 11: `format-validators` + `code-guidelines/principles`

**Status:** Completed | **Completed:** 2026-05-21 | **Deps:** 2 | **Token budget:** ~25k | **Time:** 1h

- [x] `skills/_shared/format-validators/` — 5 files (EN; Git-only; PRD validator)
- [x] `skills/_shared/code-guidelines/principles/` — 6 files (EN)
- [x] `skills/_shared/code-guidelines/README.md` — EN lazy-load index; `languages/dotnet` deferred v1.1

**Implementation notes:**

- `feature-validator.md` adapted to PRD template (`spec/reference.md`)
- Commit validator aligned with `step-4-commits-pr.md` (optional `Refs: #issue`)
- PR comment validator: English labels; generic footer

**Acceptance:** principles/ EN; validators EN. ✅

---

### ✅ ETAPA 12: QA pass — structure + cross-reference audit

**Status:** Completed | **Completed:** 2026-05-21 | **Deps:** 3–11 | **Token budget:** ~30k | **Time:** 1h

- [x] All `skills/*/SKILL.md` ≤ 150 lines
- [x] Cross-reference audit: all referenced files exist on disk
- [x] Fixed ambiguous lazy-load paths in `dotnet-developer`, `code-review`, `implement/reference.md`, `step-0.5-review-guidelines.md`

**Implementation notes:**

- Short paths like `developer-common/foo` in top-level skills replaced with `~/.cursor/skills/_shared/...` for post-sync resolution
- YAML frontmatter verified on all 6 `skills/*/SKILL.md` (`name`, `description`)

**Acceptance:** Skills within line limit; references valid. ✅

---

### ✅ ETAPA 13 (optional): Hooks — context + PLAN checkpoint

**Status:** Completed | **Completed:** 2026-05-21 | **Deps:** 12 | **Token budget:** ~25k | **Time:** 1.5h

- [x] `hooks/hooks.json` — `beforeSubmitPrompt`, `afterFileEdit`, `preCompact` (PowerShell commands)
- [x] `hooks/context-before-prompt.ps1`, `plan-after-edit.ps1`, `context-pre-compact.ps1`, `_hook-common.ps1`
- [x] `docs/HOOKS.md` — limits (no model selection, no JSONL, no `additional_context` on submit)
- [x] `rules/user-language-pt-br.md` — always reply pt-BR (user request)
- [x] README + AGENTS.md updated

**Implementation notes:**

- Smoke tests PASS on Windows PowerShell (`continue:true`, `user_message` at 85% compaction)
- State under `~/.cursor/hooks-state/` (`sdd-session.json`, `plan-edit.json`)
- Install to `~/.cursor/` deferred to ETAPA 14 (`sync-cursor.ps1` merge)

**Acceptance:** Hooks run on Windows PowerShell; README explains limits. ✅

---

### ✅ ETAPA 14 (optional): `sync-cursor.ps1` + install doc

**Status:** Completed | **Completed:** 2026-05-21 | **Deps:** 12 | **Token budget:** ~20k | **Time:** 1h

- [x] `scripts/sync-cursor.ps1` — AGENTS.md, skills/, rules/ (`.md` → `.mdc`), hooks scripts, additive `hooks.json` merge
- [x] README Quick Start (deploy, `-DryRun`, install table)
- [x] `docs/HOOKS.md` install section points to sync script

**Implementation notes:**

- SHA-256 per file; second run reports idempotent (verified on Windows PowerShell 5.1)
- `hooks.json` serialized with explicit hook entry arrays (PS 5.1 single-element unwrap fix)
- Does not touch `settings.json`, `mcp.json`, or other unrelated `~/.cursor/` files

**Acceptance:** One command deploys toolkit; idempotent. ✅

---

## Execution order

**Critical path MVP (no optional):** 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12

**Next step:** MVP complete — optional: `use skill code-review`, manual SDD smoke test, `use skill commit`

---

## Final checklist

- [x] MVP usable in Cursor from `~/.cursor/`
- [x] Token budget doc matches actual splits
- [x] Neutral branding throughout repo
- [x] xUnit/Moq/Should_When_ documented
- [ ] SDD cycle spec → plan → implement verified on dummy feature
