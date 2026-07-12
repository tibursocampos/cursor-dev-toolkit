---
name: orchestrate-develop
description: Forma C O3: one Task subagent per PLAN step (sdd-develop contract); parent never writes app code. Updates CONTINUITY; handoff to code-review. Use when invoking /orchestrate-develop.
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

# Skill: orchestrate-develop

## Trigger

Invoke when the user asks for: `/orchestrate-develop`, `orchestrate develop`, `/orchestrate-develop`, or Forma C O3 after O2 handoff.

Required: full feature path **or** a specific `PLAN/PLAN_NNN_*.md` path under a story.

## Outcome

1. Pending PLAN step(s) executed **only** via Task children that follow the **`sdd-develop` contract** (one PLAN step per child / session)
2. Feature `CONTINUITY.md` updated (phase `develop`, progress, typed next invoke)
3. Handoff to `code-review` (`- single` or `- multi-angle`; skill asks if omitted) and/or next step / next story

**Parent orchestrator never** writes application code, never marks multiple PLAN steps done in one child, and never bypasses `sdd-develop` gates (`step_confirmed`, tests before complete).

**Alternative (always valid):** user runs manual `/sdd-develop - <full-plan-path> - Step N` without this skill (RF05 / CA5).

## Lazy-load

| When | Path |
|------|------|
| Pipeline Forma C, paths | `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md` |
| Storage | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| Develop contract (source of truth) | `~/.cursor/skills/sdd-develop/SKILL.md` + `reference.md` |
| SESSION gates | `~/.cursor/skills/_shared/sdd-artifacts/SESSION.md` |
| CONTINUITY template | `~/.cursor/skills/_shared/templates/features/CONTINUITY.md` |
| Anti-bypass, parallelism, handoffs | `skills/orchestrate-develop/reference.md` |
| Code review (ask mode) | `~/.cursor/skills/code-review/SKILL.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 1. Gate check

Report the Step -1 gate checklist in chat. Load `PIPELINE.md` (Forma C) and `SESSION.md`. **STOP** if any gate unchecked. Ask user **sim** before spawning the first develop child.

### 2. Resolve feature / PLAN set

Load `STORAGE.md` (`$Workflow = classic`).

**Path sanitize (required):** normalize invoke paths; reject `..` and any resolved path outside `$Cwd/features/` (repository) or `<classic.path>/features/` (global). For a single PLAN path, it must remain under that features root. Ask again in pt-BR if invalid.

| Invoke | Action |
|--------|--------|
| Feature path | Glob `**/PLAN/PLAN_*.md` under that feature; build story/PLAN queue |
| Single PLAN path | Work that PLAN only; still update feature `CONTINUITY.md` if present |
| Missing PLAN | **STOP** — suggest O2 or Forma A |

```text
Não encontrei PLAN sob `{path}`.

1) /orchestrate-deliver - <full-feature-path>
2) /sdd-plan - <full-prd-path>
3) cancelar
```

`Read` `FEATURE.md` + `CONTINUITY.md` when under a feature. Prefer O2-approved stories; if PLAN exists but approval unclear, ask once (pt-BR) before spawning.

### 3. Build step queue (deps)

For each PLAN:

1. Parse pending steps (`⏳` / Status Pendente / unchecked).
2. Respect **Deps:** only enqueue a step when dependency steps are **Concluídos** / **Completed**.
3. Default order: one story at a time (finish story A before story B) unless user asks otherwise **and** stories are independent.

Present queue summary (pt-BR): story, PLAN path, next step id/title, deps. Confirm:

```text
Fila O3: próximo = `{plan-path}` Step {N} — {title}.

Posso spawnar o subagente (contrato sdd-develop)?
(sim / ajustar / cancelar)
```

Silence ≠ approval (RN01).

### 4. Spawn exactly one step child (CA5)

**Hard rule:** one Task = one PLAN step = full `sdd-develop` contract.

Child must:

1. Load and follow `sdd-develop/SKILL.md` (gates, validate step, git branch, implement, tests, update PLAN, report)
2. Receive **only** that PLAN path + step number + lean Prior context paths (not full guideline dumps)
3. Use **PLAN-scoped SESSION** per `SESSION.md` (`plan-{planHash}.json`, or `plan-{planHash}-step-{N}.json` when this spawn is parallel on the same PLAN)
4. Return: `{ planPath, step, status, files[], testsSummary, nextStep?, blockedReason? }`
5. **STOP** after that step — must not start Step N+1 in the same child

**Parent must not:**

- Edit `*.cs` / app sources / tests itself
- “Help finish” the child’s implementation
- Spawn a child with instructions to do Steps N and N+1
- Mark PLAN checkboxes for steps the child did not complete
- Skip `tests_run` / treat silence as step approval inside the child
- Share one flat `{repo-hash}.json` develop gate across parallel children

After child returns: parent updates `CONTINUITY.md` only (synthesis + paths). Then either hand off to a **new chat** for the next step, or ask **sim** again before the next spawn in this conversation — never auto-chain without a gate.

### 5. Safe parallelism (optional)

Default: **serial** — one step in flight (lower context risk).

Parallel Task children **when all** of:

| Condition | Required |
|-----------|----------|
| Distinct PLAN files **or** PLAN explicitly marks steps as independent / parallel-safe | Yes |
| No shared files in step scopes (parent Grep/diff intent) | Yes |
| Deps of each parallel step already complete | Yes |
| User explicitly chose parallel after being asked | Yes |
| **Distinct develop session files** (PLAN-scoped, or PLAN+step when same PLAN) | Yes |

Ask (pt-BR) before any parallel spawn:

```text
Steps {A} e {B} parecem independentes. Executar em paralelo?
(sim / série / cancelar)
```

| Parallel case | Session file per child (`SESSION.md`) |
|---------------|----------------------------------------|
| Different PLANs | `sessions/{repoHash}/plan-{planHash}.json` each |
| Same PLAN, parallel-safe steps | `sessions/{repoHash}/plan-{planHash}-step-{N}.json` each |

Child prompt **must** include: `planPath`, `step`, and “load develop SESSION scoped per SESSION.md (PLAN or PLAN+step)”.

If unsure about file independence → **série**. **Cap: 4** concurrent parallel children; if more steps qualify, wave ≤4 or stay serial. No git worktrees multi-US in MVP (RNF04). Parallelism is supported via scoped sessions — do **not** disable parallel as the only safe path.

**Same-PLAN scope rule:** if any `plan-{planHash}-step-*.json` exists for the PLAN, every spawn for that PLAN (including later serial ones) **must** use PLAN+step session files — do not mix with `plan-{planHash}.json`.

### 6. Stop conditions

Stop spawning and emit handoff when any of:

| Event | Action |
|-------|--------|
| Story PLAN all steps complete | Offer next story or code-review |
| Feature all PLANs complete | Phase → review; code-review handoff |
| Context pressure (TE02) | Persist CONTINUITY per `context-management.mdc`; resume invoke |
| Context hard-stop | Hard stop; new chat required |
| Child blocked / tests fail | Do not mark step done; report; wait for user |
| User **cancelar** | Leave CONTINUITY with pending next step |

Resume string:

```text
/orchestrate-develop - <full-feature-path>
```

Or per PLAN:

```text
/orchestrate-develop - <full-plan-path>
```

### 7. CONTINUITY

On each meaningful milestone (before/after child, pause, story done):

| Field | Rule |
|-------|------|
| **Phase** | `develop` (or `review` when all done) |
| **Last agent** | `orchestrate-develop` |
| **Estado atual** | Short per CONTINUITY template: active PLAN, last step done, next step |
| **Handoff tipado** | Exact next `/…` with **full paths** |

Do not paste full diffs or guideline bodies into CONTINUITY.

### 8. Handoff — code-review + manual alternative

When a story or feature develop pass completes (or user asks to review mid-way):

```text
## Handoff O3 → review

/code-review
/code-review - single
/code-review - multi-angle

## Continuar develop manual (alternativa a O3)
/sdd-develop - <full-plan-path> - Step {N}

## Continuar O3
/orchestrate-develop - <full-feature-path>
```

Suggest `/code-review` (user may pass `- single` or `- multi-angle`; if omitted, **code-review asks**). Never require a mode. O3 does **not** auto-block the pipeline on review.

## Anti-bypass checklist (must enforce)

Parent and children **must not**:

- [ ] Parent implements application/production code or tests
- [ ] One child executes multiple PLAN steps
- [ ] Parent marks steps complete without child success + tests
- [ ] Skip SESSION / user **sim** for the next step spawn
- [ ] Share one flat `{repo-hash}.json` for `step_confirmed` / `tests_run` across parallel children (must use PLAN-scoped or PLAN+step files)
- [ ] Rewrite `sdd-develop` into a looser “fast path”
- [ ] Call `*-developer` from parent to implement the PLAN step (route only via sdd-develop contract in the child)
- [ ] Silence treated as approval

Full copy in `reference.md`.

## Must not

- Parent writes application/production code or tests
- Merge N PLAN steps into one Task / one session context
- Bypass or weaken `sdd-develop` one-step-per-session contract
- Auto-commit / auto-push
- Create ADO / Celebration / Keycloak / mandatory Sonar corp content
- Force multi-angle code-review
- Introduce git worktrees for multi-US parallelism (MVP)
- Write new PRD/PLAN (O2 / sdd-spec / sdd-plan own that)

## Handoff

| Situation | Next |
|-----------|------|
| Next PLAN step | New chat → `orchestrate-develop` **or** `sdd-develop - <plan> - Step N` |
| Story/feature done | `/code-review` (pass `- single` / `- multi-angle`, or let skill ask) |
| Missing PLAN | `orchestrate-deliver` / `sdd-plan` |
| Prefer no orchestrator | Manual `sdd-develop` only |

### Canonical strings

```text
/orchestrate-develop - <full-feature-path>
```

```text
/sdd-develop - <full-plan-path> - Step N
```

```text
/code-review
/code-review - multi-angle
```
