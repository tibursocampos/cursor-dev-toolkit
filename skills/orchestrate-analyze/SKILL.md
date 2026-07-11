---
name: orchestrate-analyze
description: Forma C O1 - triage a feature (complexity/nature/scope), spawn conditional Task specialists from needs_* flags, and write FEATURE.md + CONTINUITY.md + US/TS STORY.md under features/NNN-slug/. Human backlog approval before O2. Does not implement app code. Use when the user says "use skill orchestrate-analyze", "orchestrate analyze", or "/orchestrate-analyze".
---

## STOP - Read before ANY tool call

1. Read `~/.cursor/rules/guardrails.mdc`
2. Read `_shared/sdd-artifacts/SESSION.md`; load session-state for `$Cwd`
3. If the relevant gate is not approved: **STOP** - ask user **(pt-BR)** - do **NOT** Write/Shell
4. SDD/develop skills: after **ONE** step/task, **STOP** session - handoff only
5. This skill body is **English**; user-facing prompts may be **(pt-BR)**

### Step -1 - Gate check (report in chat before continuing)

```
Gate check:
[ ] guardrails.mdc read
[ ] SESSION.md read; session-state loaded
[ ] PIPELINE.md read (required for orchestrate-*)
[ ] User confirmed current action (sim)
-> If any unchecked: STOP
```

---

# Skill: orchestrate-analyze

## Trigger

Invoke when the user asks for: `use skill orchestrate-analyze`, `orchestrate analyze`, `/orchestrate-analyze`, or Forma C analysis for a complex / multi-story / brownfield feature.

Optional: pasted feature description, existing notes path, or prior refine output.

## Outcome

Under the resolved classic feature root (`STORAGE.md`, `$Workflow = classic`):

1. `features/NNN-slug/FEATURE.md` — triage, scope, nature, complexity, `needs_*`
2. `features/NNN-slug/CONTINUITY.md` — phase, decisions, typed handoff
3. `features/NNN-slug/USnn/STORY.md` and/or `TSnn/STORY.md` — BDD + scorecard summary + deps

**Human gate:** backlog must be explicitly approved (`sim` / `ajustar` / `cancelar`) before O2. **Silence is not approval** (RN01).

Orchestrator **does not** implement application code. Specialists write notes under story `ANALYSIS/` / `ARCH/` / `SEC/` only when spawned.

Does **not** write PRD/PLAN (that is O2 via `sdd-spec` / `sdd-plan` contracts). Does **not** call trackers.

## Lazy-load

| When | Path |
|------|------|
| Pipeline Forma C, confirm, paths | `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md` |
| Storage, manifest, feature tree | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| Roster, `needs_*`, triage table | `~/.cursor/skills/_shared/agents/ROSTER.md` |
| Stack routing (implement later) | `~/.cursor/skills/_shared/agents/ROUTING.md` |
| Templates | `~/.cursor/skills/_shared/templates/features/{FEATURE,CONTINUITY,TREE}.md`, `.../story/STORY.md` |
| Specialist prompts | `~/.cursor/skills/_shared/agents/prompts/{repo_analyst,architect,security,database,impact,risk,generate-story}.md` |
| Triage tables, boundaries, NuGet example | `skills/orchestrate-analyze/reference.md` |
| Scorecard rubric (reuse) | `skills/refine-backlog-item/reference.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 1. Gate check

Report the Step -1 gate checklist in chat. Load `PIPELINE.md` (Forma C) and `SESSION.md`. **STOP** if any gate unchecked.

### 2. Resolve storage

Load `STORAGE.md`. Run resolution with `$Workflow = classic`. Resolve feature root:

- **repository** → `$Cwd/features/`
- **global** → `<classic.path>/features/`

**Path sanitize (required)** for any invoke / allocated feature path: normalize (`\` → `/`, trim trailing `/`, resolve `.`). Reject if it contains `..`, or if the resolved absolute path is **not** under the feature root above. Ask again in pt-BR for a canonical path — do not Read/Write outside the feature root.

If first run for this repo: ask storage (pt-BR) per `STORAGE.md` and persist manifest. Confirm target workspace. Do **not** invent a feature path outside the resolved root.

Repository mode: ensure SDD `.gitignore` patterns per `STORAGE.md` when writing under `features/` (do not weaken toolkit patterns; never ignore `skills/`).

### 3. Collect description and triage

Ask for (or reuse Prior context): goal, current behavior, constraints, known repos/areas.

Set and record:

| Dimension | Values |
|-----------|--------|
| Complexity | `trivial` \| `medium` \| `complex` |
| Nature | `greenfield` \| `brownfield` \| `operational` |
| Scope | `backend` \| `frontend` \| `fullstack` |

Set `needs_*` flags (`needs_api`, `needs_domain`, `needs_database`, `needs_frontend`, `needs_security`, `needs_devops`) using the **canonical table in `ROSTER.md`** (do not fork a second mapping here). Optional NuGet/examples: `reference.md`.

**TE01 — ambiguous flags:** ask at most a few high-cost questions (pt-BR). Do **not** invent architecture in the orchestrator. Prefer `false` until evidence or user confirms — **except** auth / secrets / PII / feed-token / supply-chain signals → ask explicitly or set `needs_security=true`.

Suggest path (RF01):

| Complexity | Suggestion |
|------------|------------|
| `trivial` | Shortcut `developer` / stack `*-developer` (step 4) |
| `medium` | Forma A (`sdd-spec` → `sdd-plan` → `sdd-develop`) **or** continue O1 if multi-story |
| `complex` | Continue full O1 (this skill) |

### 4. Trivial shortcut

If `trivial`: recommend skipping full O1 write:

```text
Escopo trivial. Prefere atalho?

1) use skill developer  (ou *-developer do stack)
2) Continuar O1 mesmo assim (gravar feature tree)
3) cancelar
```

Only continue to step 5+ if the user explicitly chooses **2**.

### 5. Allocate NNN-slug and scaffold tree

1. Glob existing `NNN` under `features/*/` only (workspace + global feature root) per `STORAGE.md`. Next = max + 1. Do **not** number from root/flat `PRD/` or `PLAN/`.
2. Propose `NNN-slug` (kebab-case) and **full path**.
3. Confirm before first Write (pt-BR): **“Posso gravar a árvore em `{path}`? (sim / ajustar / cancelar)”** — silence ≠ approval.
4. Create from templates: `FEATURE.md`, `CONTINUITY.md`, story folders `USnn`/`TSnn` as needed. Optional subfolders (`ANALYSIS/`, `ARCH/`, `SEC/`, `REFINE/`) **on demand** under the story — never at repo root. Do **not** create `PRD/` / `PLAN/` yet (O2).

### 6. Spawn Task specialists (conditional, parallel)

Spawn a Task subagent **only** when `ROSTER.md` canonical `needs_*` / brownfield rules say so. Load prompt from `skills/_shared/agents/prompts/`. When multiple specialists apply, spawn **in parallel** — **cap: 4** concurrent Tasks; if more flags apply, batch in waves of ≤4 or ask (pt-BR) to run série.

| Signal (see ROSTER) | Specialist | Prompt |
|---------------------|------------|--------|
| `needs_api` or brownfield / impact unclear | `repo_analyst` | `prompts/repo_analyst.md` |
| `needs_domain` or contract-heavy API | `architect` | `prompts/architect.md` |
| `needs_database` | `database` | `prompts/database.md` |
| `needs_security` | `security` | `prompts/security.md` |
| `needs_frontend` | *(no O1 specialist)* — note in CONTINUITY; route at implement via `ROUTING.md` |
| `needs_devops` | short CONTINUITY note only | — |
| Story drafting aid | use `generate-story` patterns | `prompts/generate-story.md` |
| Optional stage notes | `impact` / `risk` | `prompts/impact.md`, `prompts/risk.md` |

Parent keeps lean context: synthesis + paths. Specialists must **not** write app code. Do **not** call `*-developer` to implement. `qa_checklist` is CONTINUITY/STORY only — never spawn a Task for it.

### 7. Synthesize artifacts

Merge specialist notes + user input into:

1. **FEATURE.md** — overview, story index, all `needs_*`, status `draft`
2. **CONTINUITY.md** — phase `analyze`, decisions, flags, open items
3. **STORY.md** per US/TS — template structure; BDD Given/When/Then; deps; scorecard summary (rubric from `refine-backlog-item/reference.md`; map /100 → 1–5 in STORY table)

Use `generate-story` prompt patterns for drafts. Prefer pt-BR artifact prose; paths/ids English.

### 8. Human backlog approval (RN01)

Present the backlog (feature summary + story table + scorecard highlights). Ask (pt-BR):

```text
Backlog O1 pronto em `{feature-path}`.

Posso marcar como aprovado e seguir para O2?
(sim / ajustar / cancelar)
```

| Answer | Action |
|--------|--------|
| **sim** | status → `approved`; continue step 9 |
| **ajustar** | revise stories/flags; re-present; ask again |
| **cancelar** | leave `draft`; do not hand off to O2 |
| *(silence / other)* | **not** approval — wait |

### 9. Approve → CONTINUITY + O2 handoff

On **sim**:

1. Update `FEATURE.md` / story statuses to `approved` as appropriate.
2. Update `CONTINUITY.md`: phase stays `analyze` until O2 starts (or set handoff-ready note); `Last agent` = `orchestrate-analyze`; typed handoff string.
3. Offer O2 (document series vs parallel as **O2 choice** — do not implement O2 here):

```text
use skill orchestrate-deliver - <full-feature-path>
```

Example:

```text
use skill orchestrate-deliver - features/004-nuget-extract/
```

Remind (pt-BR): O2 will ask série vs paralelo for per-story PRD/PLAN.

### 10. Context pressure (TE02 / RNF02)

Honor `~/.cursor/rules/context-management.mdc` thresholds (checkpoint / hard stop). When pressure is high:

1. Persist latest `CONTINUITY.md` (estado atual short per CONTINUITY template, decisões, pendências, exact next `use skill …`).
2. Offer session handoff — same phase, resume with feature path:

```text
use skill orchestrate-analyze - <full-feature-path>
```

Do **not** paste full specialist dumps into the parent chat.

## Must not

- Write application/production code or tests (`*.cs`, `*.tsx`, `*.ts`, `*.js`, `*.vue`, `*.py`, migrations, etc.)
- Call `*-developer` / `developer` to **implement** code (suggesting the trivial shortcut is allowed)
- Skip human backlog approval or treat silence as `sim`
- Write PRD/PLAN (O2 owns that via `sdd-spec` / `sdd-plan` contracts)
- Create ADO / Celebration / Keycloak / mandatory Sonar corp content
- Create ~40 agent files or expand the roster beyond `ROSTER.md`
- Modify toolkit `.gitignore` as part of porting this skill into the toolkit repo; at runtime follow `STORAGE.md` only for consumer repo SDD patterns
- Change the `sdd-develop` one-step-per-session contract
- Create `REFINE/` / `ANALYSIS/` / `ARCH/` / `SEC/` / `PRD/` / `PLAN/` at **repo root**
- Resolve feature paths outside `$Cwd/features/` or `<classic.path>/features/`, or accept `..` segments

## Handoff

| Situation | Next |
|-----------|------|
| Backlog approved | `use skill orchestrate-deliver - <full-feature-path>` |
| Context pause mid-O1 | `use skill orchestrate-analyze - <full-feature-path>` |
| Trivial after triage | `use skill developer` or stack `*-developer` |
| Single clear story, skip O2 multi | `use skill sdd-spec` (Forma A) after STORY exists |
| Informal single item only | `use skill refine-backlog-item` (Forma B) |

### Canonical O2 handoff (exact pattern)

```text
use skill orchestrate-deliver - <full-feature-path>
```
