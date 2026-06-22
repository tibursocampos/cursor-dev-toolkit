# breakdown-tasks - reference

Grouping heuristics and templates for `skills/breakdown-tasks/SKILL.md`. Keep `SKILL.md` under 500 lines; use this file for extended detail.

---

## Parsing steps from refined markdown

| Item type | Section headings to search |
|-----------|---------------------------|
| User Story / Technical Story | `### 🧩 Steps` |
| Bug | `### 🧩 Suggested fix` under Error, or `### 🧩 Steps` |

Each step block typically matches:

```markdown
**Step N - [Title]**
[description]
- Layer: [...]
- Depends on: [...]
```

Also accept legacy Portuguese headings from older notes: `**Etapa N -` (normalize to Step N in output).

If only a bullet list without step headers, ask the user to re-run `refine-backlog-item` or confirm grouping manually.

---

## Grouping heuristics

Apply in order:

**a) Markdown sub-headings (`####`)** - e.g. `#### Backend - billing-api` -> one group per heading.

**b) Repository / service name** - steps mentioning different repos or deployable units group separately.

**c) Layer** - same repo but clear split: Domain/Application/Infrastructure/API -> "Backend"; UI/Angular/React -> "Frontend".

**d) Fallback** - ≤3 steps with no natural split -> single group `Implementation`.

**Limits:**

- Maximum **5** implementation groups - merge smallest adjacent groups if exceeded
- Minimum **1** implementation group when any non-test steps exist

**Test steps (mandatory split):**

Steps whose layer is `Tests`, `Integration tests`, `Testes`, or title contains "unit test" / "integration test" -> move to:

- `Tests - Backend` and/or
- `Tests - Frontend`

Do not leave test-only steps inside feature implementation groups.

---

## Output template (`docs/sdd-developation-tasks/<slug>.md`)

```markdown
# Implementation tasks: [title]

| Field | Value |
|-------|--------|
| **Source** | docs/backlog/<slug>.md \| chat |
| **Doc language** | pt-BR \| English |
| **Repository** | [name] |
| **Progress** | 0/N groups |

## Summary

| Group | Steps | Status |
|-------|-------|--------|
| Implement [Group 1] | 1-3 | Pending |
| Implement [Group 2] | 4-5 | Pending |
| Tests - Backend | 6 | Pending |

---

## Implementation

### Group 1: [name]

**Steps covered:** 1-2

- [ ] **Step 1 - [title]**
  - Layer: [...]
  - Depends on: none
- [ ] **Step 2 - [title]**
  - Layer: [...]
  - Depends on: Step 1

### Group 2: [name]

**Steps covered:** 3-4

- [ ] **Step 3 - [title]**
  ...

---

## Tests

### Tests - Backend

**Steps covered:** 5

- [ ] **Step 5 - [title]**
  ...

### Tests - Frontend (omit if none)

- [ ] **Step N - [title]**

---

## Before PR (optional - neutral checklist)

Use only if the team wants a local reminder block. **Not** required for skill completion.

- [ ] Build and targeted tests pass locally
- [ ] Acceptance criteria from backlog item re-read
- [ ] PR description lists scope and test evidence
- [ ] No secrets or local paths in diff

---

## Execution order

**Critical path:** Group 1 -> Group 2 -> … -> Tests

**Next:** Group 1 - [name]

## SDD handoff

When scope is medium/high complexity:

```
use skill sdd-spec -> use skill sdd-plan -> use skill sdd-develop
```

This file is **input** for planning - it does not replace `PLAN/PLAN_*.md`.
```

Update **Progress** and group **Status** when the user completes work in a follow-up session (optional manual edit).

---

## SDD PLAN resolution (read-only)

When the handoff table says **PLAN already exists**, resolve the path before suggesting `sdd-develop`:

1. Load `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md`.
2. Read manifest when valid for the open workspace (`workspace_root` match).
3. Glob workspace: `PLAN/PLAN_*.md`; global: `~/.cursor/sdd/<repo-id>/PLAN/PLAN_*.md`.
4. If the user named a feature or `NNN`, pick the matching `PLAN_NNN_*.md`; if one PLAN clearly matches the backlog slug/title, use it.
5. If zero or multiple PLANs remain, ask once in pt-BR with numbered full paths - do not assume `PLAN/` at repo root is empty means no global PLAN.
6. Pass **full path** in the handoff (relative to workspace or absolute under `~/.cursor/sdd/`).

Do **not** use `docs/documentation-plan/plan.md` (that is `document-plan` / `document-implement`, not SDD).

Mirror full PRD+PLAN pairing rules in `skills/code-review/reference.md` § SDD artifact resolution when both artifacts are needed.

---

## Boundary: breakdown-tasks vs plan

| Aspect | `breakdown-tasks` | `plan` (SDD) |
|--------|-------------------|--------------|
| Input | Refined backlog steps | PRD acceptance criteria |
| Output | `docs/sdd-developation-tasks/<slug>.md` | `PLAN/PLAN_*.md` or `~/.cursor/sdd/<repo-id>/PLAN/PLAN_*.md` |
| Granularity | Engineering grouping for one item | Baby steps across a feature with deps and token budget |
| Tracker | Never | Never (Git-only toolkit) |

Use `plan` after `spec` for toolkit SDD flow. Use `breakdown-tasks` for quick local checklists from refine.

---

## Optional QA / PR hints (neutral)

Teams may add a short **Verification** subsection per group:

```markdown
**Verification:** Re-run scenarios [1-2] from backlog acceptance criteria after this group.
```

Do not reference proprietary observability URLs or mandatory desk-check fields unless the user supplies them.

---

## Explicit exclusions (ported from corporate plan-task)

Do **not** auto-generate:

- "Update AI tags" / SDD / DevAI tag tasks
- "Attach Datadog logs" as a fixed task
- DeskCheck / DESKCHECK tag tasks
- "Review own PR" with Sonar/Snyk boilerplate as mandatory rows
- Child tasks on remote boards via REST PATCH

If the user wants a custom workflow section, add it under **Before PR** with their wording only.

---

## Context management

Per `~/.cursor/rules/context-management.mdc`: after writing a large checklist, checkpoint at ≥ 40% context; hand off continuation with file path and next group id.
