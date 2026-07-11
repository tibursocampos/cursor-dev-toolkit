# orchestrate-develop - reference

Anti-bypass checklist, step queue, safe parallelism, CONTINUITY, Task child prompt, and handoffs for `skills/orchestrate-develop/SKILL.md`. Keep `SKILL.md` lean.

---

## Preconditions checklist

- [ ] Gate check reported; user **sim** for this O3 run / next spawn
- [ ] Feature and/or PLAN path resolved (`STORAGE.md`, classic)
- [ ] At least one `features/**/PLAN/PLAN_*.md` under story folders (or global `.../features/**/PLAN/`)
- [ ] Next step deps **Completed** / **Concluídos**
- [ ] Parent will **not** implement app code

If no PLAN → hand off to O2 / `sdd-plan`. If user prefers no orchestrator → document manual `sdd-develop` and stop.

---

## Anti-bypass checklist (CA5) — copy into enforcement

Use before every spawn and before marking any step done.

| # | Rule | Violates if |
|---|------|-------------|
| 1 | Parent writes **no** app/test source | Parent `Write`/`Edit` on `*.cs`, `*.tsx`, migrations, etc. |
| 2 | One Task = **one** PLAN step | Child prompt lists Steps N and N+1 |
| 3 | Child follows full `sdd-develop` contract | “Quick implement without gates/tests” |
| 4 | Tests before complete | PLAN marked done with failing/skipped tests |
| 5 | User **sim** before next spawn | Auto-chain N steps after one **sim** |
| 6 | Silence ≠ approval | Proceeding without explicit **sim** |
| 7 | Manual `sdd-develop` always allowed | Skill claims O3 is mandatory |
| 8 | No contract fork | Parallel undocumented “O3 implement” process |
| 9 | No `*-developer` from parent for PLAN steps | Parent implements via stack skill instead of child sdd-develop |
| 10 | CONTINUITY only in parent after child | Parent pastes full diffs as “implementation” |

Any violation → **STOP**, fix process, do not mark step complete.

---

## Step queue algorithm

```text
1. Collect PLANs under feature (or single PLAN from invoke).
2. For each PLAN, list steps with status + deps.
3. Ready set = pending steps whose deps are all completed.
4. Default pick = first ready in PLAN order within current story.
5. Present pick; wait for sim; spawn one child.
6. On success: refresh queue; update CONTINUITY; ask sim for next OR hand off new chat.
7. On failure: keep step pending; report blockedReason; do not advance.
```

Story preference: finish one story’s PLAN before starting another unless user explicitly reorders and deps allow.

---

## Safe parallelism rules

Parallel O3 is **supported**. Root cause of gate races is fixed by PLAN-scoped (or PLAN+step) develop sessions in `SESSION.md` — not by disabling parallel, not by worktrees.

| Allowed | Not allowed |
|---------|-------------|
| Two ready steps on **different** PLANs with disjoint file scopes + distinct `plan-{hash}.json` + user **sim** | Two children sharing one flat `{repo-hash}.json` for `step_confirmed` / `tests_run` |
| Same PLAN steps marked parallel-safe + disjoint files + `plan-{hash}-step-{N}.json` each | Guessing independence without asking |
| Serial default when unsure | Worktrees / multi-checkout for multi-US (out of MVP) |

Ask before parallel:

```text
Steps {A} e {B} parecem independentes. Executar em paralelo?
(sim / série / cancelar)
```

Each child prompt must include `planPath`, `step`, and instruction to use the matching scoped SESSION file.

---

## Contract reuse (RN05)

| Concern | Source of truth |
|---------|-----------------|
| One step per session | `sdd-develop/SKILL.md` |
| PLAN update protocol | `sdd-develop/reference.md` |
| SESSION gates | `SESSION.md` (repo + PLAN-scoped develop) + guardrails |
| Branch rules | `branch-validation.mdc` via sdd-develop |

O3 **orchestrates invocation**; it does **not** replace those documents.

---

## Task child prompt skeleton

Give each child:

1. Exact PLAN path + step number/title
2. Instruction: execute `use skill sdd-develop` contract for **this step only** — load `sdd-develop/SKILL.md`
3. Instruction: load develop SESSION scoped per `SESSION.md` — `plan-{planHash}.json`, or `plan-{planHash}-step-{N}.json` if this is a same-PLAN parallel spawn
4. Prior-context paths only (PRD, STORY, CONTINUITY, FEATURE) — do not paste bodies
5. Must stop after updating PLAN for this step; must run targeted tests before complete
6. Return: `{ planPath, step, status: done|blocked, files[], testsSummary, nextStep?, blockedReason? }`
7. Must not: other PLAN steps; weaken gates; skip tests; auto-commit unless user asked inside that child session; write develop gates to the flat repo session when PLAN path is known

Parent: merge return → CONTINUITY → gate for next spawn.

---

## CONTINUITY checklist

Update when:

- [ ] Queue presented / mode (série default)
- [ ] After each child returns
- [ ] Story complete / feature complete
- [ ] Context ≥40% pause
- [ ] Before code-review handoff

| Field | Rule |
|-------|------|
| **Phase** | `develop` until all planned work done → `review` |
| **Last agent** | `orchestrate-develop` |
| **Estado atual** | ≤10 lines |
| **Handoff tipado** | Full path `use skill …` |
| **What not to write** | Full code diffs, guideline dumps |

---

## Example — serial two steps then review

Feature: `features/004-nuget-extract/`  
PLAN: `features/004-nuget-extract/TS01/PLAN/PLAN_004_nuget_package.md`

```text
## O3 run

1) sim → Task(sdd-develop Step 1) → CONTINUITY update
2) new chat or sim → Task(sdd-develop Step 2) → …
3) TS01 complete → handoff:

use skill code-review
use skill code-review - single
use skill code-review - multi-angle

# Manual alternative anytime:
use skill sdd-develop - features/004-nuget-extract/TS01/PLAN/PLAN_004_nuget_package.md - Step 3
```

---

## Handoff copy (pt-BR / strings)

```text
## Handoff O3 → review

use skill code-review
use skill code-review - single
use skill code-review - multi-angle

## Continuar develop manual (alternativa a O3)
use skill sdd-develop - <full-plan-path> - Step {N}

## Continuar O3
use skill orchestrate-develop - <full-feature-path>
```

Handoff `use skill code-review` (user may pass `- single` / `- multi-angle`; if omitted, skill asks). Never required; does not auto-block pipeline.

---

## Boundaries

| Aspect | O2 | O3 | Manual `sdd-develop` |
|--------|----|----|----------------------|
| Writes | PRD/PLAN | CONTINUITY + spawns implementers | Code + PLAN progress |
| App code | No | Children only | Yes (the skill itself) |
| Steps per session | N/A | **One** per child | **One** |
| Required? | After O1 for Forma C | **Optional** | Always valid |

---

## Canonical invoke strings

```text
use skill orchestrate-develop - <full-feature-path>
```

```text
use skill orchestrate-develop - <full-plan-path>
```

```text
use skill sdd-develop - <full-plan-path> - Step N
```

```text
use skill code-review
use skill code-review - single
use skill code-review - multi-angle
```

```text
use skill orchestrate-deliver - <full-feature-path>
```

---

## Explicit exclusions

- Parent implementation of app/test code
- Multi-step children or auto-chained steps without **sim**
- Forked develop process that skips sdd-develop gates
- Mandatory multi-angle review
- Git worktrees for multi-US
- ADO / Celebration / Keycloak / mandatory Sonar corp
- Spec Kit changes
- Weakening `sdd-develop` one-step contract
