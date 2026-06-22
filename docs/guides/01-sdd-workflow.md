# SDD workflow: spec, plan, implement

**Index:** [Guides README](README.md)

---

## What it is

**Spec Driven Development (SDD)** in this toolkit is a three-skill pipeline for medium or high complexity work:

1. **`spec`** - turns your feature request into a **PRD** (Product Requirements Document): what to build, acceptance criteria, scope.
2. **`plan`** - breaks the PRD into **baby steps** in a **PLAN** file (one implement session per step).
3. **`sdd-develop`** - executes **exactly one** PLAN step per chat: code, tests, and PLAN progress update.

PRD and PLAN are **agent artifacts** (usually pt-BR). Application code and tests stay **English**. User guides like this file live under `docs/guides/` and **are** versioned in git.

---

## When to use / when not to use

### Use SDD when

- The change spans **multiple areas**, components, or bounded contexts.
- You need a **migration**, API contract change, or cross-cutting design.
- Scope is **unclear** and you want acceptance criteria before coding.
- The feature is too large for a single chat session.

### Do not use SDD when

- You have a **small, isolated .NET fix or refactor** in one area with no PRD needed -> use [02 - developer](02-developer.md) instead.
- You only need to **commit**, **fix a build**, or run **coverage** -> see [05 - operational skills](05-operational-skills.md) or the post-code guides below.

When in doubt, prefer SDD. You can always stop after `spec` if the PRD reveals the work is smaller than expected.

---

## Prerequisites

1. **Toolkit installed** - run `scripts/sync-cursor.ps1` from the toolkit repo so skills live under `~/.cursor/skills/`. See [Install](../INSTALL.md).
2. **Target project open in Cursor** - the repo you are building (not necessarily `cursor-dev-toolkit`).
3. **Agent mode** - SDD writes files (PRD, PLAN, code). Plan or Ask mode drafts in chat only until you confirm **sim** (yes) for the write.
4. **Feature branch** - before `sdd-develop`, work on `feature/<slug>` or `feat/<id>`, not `main`, `master`, or `develop`.
5. **Storage choice understood** - PRD/PLAN go to repo `PRD/` and `PLAN/` **or** global `~/.cursor/sdd/<repo-id>/`. Both are typically **gitignored** when stored in the repo. Do not expect them in pull requests.

Full storage rules: `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` (after sync).

---

## How to invoke

Use these exact phrases in chat (English trigger, as in [AGENTS.md](../../AGENTS.md)):

| Phase | Invoke |
|-------|--------|
| Create PRD | `use skill sdd-spec` |
| Create PLAN from PRD | `use skill sdd-plan - <prd-path>` |
| Execute one PLAN step | `use skill sdd-develop - <plan-path> - Step N` |

**Path placeholders:**

- `<prd-path>` - e.g. `PRD/001_my_feature.md` or `~/.cursor/sdd/<repo-id>/PRD/001_my_feature.md`
- `<plan-path>` - e.g. `PLAN/PLAN_001_my_feature.md` or global equivalent under `~/.cursor/sdd/<repo-id>/PLAN/`
- `<repo-id>` - stable id for your project (from SDD manifest after first `spec`)

**Checkpoint rule:** one `sdd-develop` invocation = **one** PLAN step. Start a **new chat** for the next step.

---

## Step-by-step

### Phase A - `spec` (PRD)

1. Open the **project repo** in Cursor.
2. Switch to **Agent** mode.
3. Type: `use skill sdd-spec`
4. Answer the agent’s questions (feature, current vs expected behavior, optional tracking id).
5. Review the draft summary. When the agent asks to confirm the path and storage, reply **sim** to save (or **ajustar** / **cancelar**).
6. **Output:** `PRD/NNN_short_slug.md` (or global path). Status should be ready for planning.
7. **Handoff:** `use skill sdd-plan - <full-prd-path>`

**What the agent will not do in `spec`:** write PLAN, implementation code, or commits.

### Phase B - `plan` (baby steps)

1. Ensure the PRD exists and status is **Pronto para planejamento** / **Ready for planning**.
2. Type: `use skill sdd-plan - <prd-path>` (use the **full** path from the `spec` handoff).
3. Review proposed steps (~20-45 minutes each). Confirm **sim** before the PLAN file is written.
4. **Output:** `PLAN/PLAN_NNN_*.md` with steps marked **Pendente** / pending and progress `0/N`.
5. Note **Step 1** as your first implement target.
6. **Handoff:** `use skill sdd-develop - <full-plan-path> - Step 1`

**What the agent will not do in `plan`:** implement code, overwrite your PRD, or run multiple sdd-develop steps.

### Phase C - `sdd-develop` (one step per session)

1. Check out or create a **valid feature branch**.
2. Open a **fresh chat** (recommended every step, **required** after long sessions).
3. Type: `use skill sdd-develop - <plan-path> - Step N` (replace `N` with the pending step number).
4. The agent validates dependencies (previous steps completed), implements scope, runs targeted tests if applicable.
5. The agent marks the step **Concluído** / completed in the PLAN file.
6. **Stop.** Do not ask for Step N+1 in the same session.
7. **Next session:** new chat -> `use skill sdd-develop - <plan-path> - Step N+1`

Repeat until all PLAN steps are done.

### Context checkpoint (~40%)

If the chat is long or the agent warns about context pressure (~40% of the window), **save progress and start a new chat** before the next PLAN step. Continuing past that point often causes missed handoffs or skipped PLAN updates.

---

## Minimal example

Scenario: add email validation to a signup API in your app repo (`my-app`). Three invocations, three chats.

**Chat 1 - spec**

```
You: use skill sdd-spec

Agent: [asks what to build, current vs expected behavior]

You: Add server-side email format validation on POST /signup.
     Reject invalid emails with 400 and a clear message.
     Today invalid emails are accepted.

Agent: [summary, proposed path PRD/001_signup_email_validation.md, storage repo]
       Confirm write? (sim / ajustar / cancelar)

You: sim

Agent: PRD saved. Handoff: use skill sdd-plan - PRD/001_signup_email_validation.md
```

**Chat 2 - plan**

```
You: use skill sdd-plan - PRD/001_signup_email_validation.md

Agent: [summarizes PRD, proposes 4 baby steps]
       Confirm PLAN at PLAN/PLAN_001_signup_email_validation.md? (sim / ajustar / cancelar)

You: sim

Agent: PLAN saved (0/4). First step: domain validator + unit tests.
       Handoff: use skill sdd-develop - PLAN/PLAN_001_signup_email_validation.md - Step 1
```

**Chat 3 - implement (Step 1 only)**

```
You: use skill sdd-develop - PLAN/PLAN_001_signup_email_validation.md - Step 1

Agent: [implements Step 1, updates PLAN to 1/4, marks Step 1 complete]
       Handoff: new chat -> use skill sdd-develop - PLAN/PLAN_001_signup_email_validation.md - Step 2
```

After all PLAN steps: run post-code flow ([code-review](03-code-review.md) -> [test-coverage](04-test-coverage.md) -> `commit` in [05 - operational skills](05-operational-skills.md)).

---

## Common mistakes

1. **Expecting PRD/PLAN in git history** - Agent artifacts under `PRD/` and `PLAN/` are **gitignored** in repository storage mode. They are workflow files on your machine (or under `~/.cursor/sdd/<repo-id>/`), not product deliverables. Versioned documentation for **this toolkit** lives in `docs/guides/`, which **is** committed. Do not confuse the two (TE01).

2. **Multiple PLAN steps in one `sdd-develop` session** - Each step is sized for one session. Asking for Step 2 in the same chat as Step 1 skips checkpoints, overloads context, and often leaves the PLAN file out of sync. Always open a **new chat** per step (TE02).

3. **Staying in Plan/Ask mode and never confirming `sim`** - `spec` and `plan` only **write files in Agent mode** after you confirm **sim**. Drafts in Plan/Ask stay in chat and are lost if you assume they were saved.

4. **Wrong storage or path** - Mixing repo `PRD/` with global `~/.cursor/sdd/<repo-id>/PRD/` causes “file not found” on handoff. Use the **full path** the previous skill reported; keep PRD and PLAN in the same storage mode.

5. **Ignoring the ~40% context warning** - Long explorations in one chat degrade quality. Save the PLAN update, start fresh, then invoke `sdd-develop` with the same plan path and next step number.

6. **Using SDD for a one-file bugfix** - Full SDD overhead is unnecessary for an isolated change. Switch to [developer](02-developer.md) when the decision tree in [README.md](README.md) points there.

---

## Next step

| After | Do this |
|-------|---------|
| All PLAN steps complete | `use skill code-review` - [03 - code-review](03-code-review.md) |
| .NET project with tests | `use skill test-coverage` - [04 - test-coverage](04-test-coverage.md) |
| Ready to land changes | `use skill commit` - [05 - operational skills](05-operational-skills.md) |
| Work was smaller than expected | [02 - developer](02-developer.md) for the next small task |
| Back to skill map | [Guides README](README.md) |

**Resume SDD:** new chat -> `use skill sdd-develop - <plan-path> - Step N` for the next pending step.
