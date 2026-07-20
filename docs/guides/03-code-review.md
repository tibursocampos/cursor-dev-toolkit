# code-review

**Index:** [Guides README](README.md)

---

## What it is

**`code-review`** runs a structured review of your **branch or diff** against project standards, optional **PRD/PLAN** acceptance criteria, and shared guidelines (Clean Architecture, tests, security). The agent produces a report with severity tiers and a decision: **Approved**, **Approved with reservations**, or **Changes required**.

The skill **does not modify code** unless you ask for fixes in a follow-up. It is the recommended step **after** [SDD develop (`sdd-develop`)](01-sdd-workflow.md) or [developer](02-developer.md) and **before** [commit](05-operational-skills.md) or merge.

**Review mode (ask - no silent default):** if the invoke omits **single** and **multi-angle**, the skill **asks once** (pt-BR) and waits. It never assumes single or multi.

---

## When to use / when not to use

### Use `code-review` when

- Implementation is **done** on a feature branch and you want a pre-commit or pre-PR gate.
- You followed **SDD** or **`developer`** and need traceability to PRD acceptance criteria or PLAN steps.
- You want a second pass on **correctness, architecture, tests, security**, and maintainability.
- You need a clear **go / no-go** before `/commit` or opening a pull request.

PRD and PLAN paths are **optional** in your invoke - the agent searches under `features/**/PRD` and `features/**/PLAN` (repo and global `~/.cursor/sdd/<repo-id>/features/`) per `STORAGE.md` before asking you.

### Do not use `code-review` when

- You have **not written code yet** - use [01 - SDD workflow](01-sdd-workflow.md) or [02 - developer](02-developer.md) first.
- The repo **does not build or tests fail** and you only need to fix failures -> `/repair-dotnet-build` ([05 - operational skills](05-operational-skills.md)).
- You want **coverage metrics only** -> `/test-coverage` ([04 - test-coverage](04-test-coverage.md)); run review after or combine in the post-code sequence from [README.md](README.md).

---

## Prerequisites

1. **Toolkit installed** - [Install](../INSTALL.md) and `scripts/sync-cursor.ps1`.
2. **Target project open in Cursor** - the repo under review.
3. **Git state** - changes on a **feature branch** (`feature/<slug>` or `feat/<id>`), not uncommitted work you do not intend to review (or say so explicitly).
4. **Base branch known** - usually `main` or `develop`; tell the agent if your repo uses another default.
5. **Optional SDD artifacts** - if you used SDD, PRD/PLAN live under the feature tree only:
   - Repo: `features/NNN-slug/USnn/PRD/`, `features/NNN-slug/USnn/PLAN/` (often gitignored via `/features/`), or
   - Global: `~/.cursor/sdd/<repo-id>/features/NNN-slug/USnn/PRD/` and `.../PLAN/`

Storage summary: see [Install](../INSTALL.md) and `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` (after sync). Discovery does **not** use root `PRD/` or `PLAN/` as primary locations.

---

## How to invoke

Primary invoke:

```
/code-review
```

Alternatives: `review this PR`, `/code-review`.

**Review mode (mandatory - no silent default):**

| Mode | Explicit invoke examples |
|------|--------------------------|
| **Single** | `/code-review - single` |
| **Multi-angle** | `/code-review - multi-angle` |

If you omit both, the agent asks (pt-BR) and waits:

```text
Modo de code-review?
1) single - um revisor
2) multi-ângulo - qualidade + aceite + segurança (ou diga o subset)
```

**Variants (add detail in the same message):**

| Goal | Example invoke |
|------|----------------|
| Default scope + ask mode | `/code-review` |
| Named branches + single | `/code-review - single - compare feature/order-export against main` |
| Explicit SDD paths | `/code-review - single - features/001-order-export/US01/PRD/001_order_export.md features/001-order-export/US01/PLAN/PLAN_001_order_export.md` |
| Global SDD storage | `/code-review - single - ~/.cursor/sdd/<repo-id>/features/001-order-export/US01/PRD/001_*.md` |
| Quick review (no SDD) | `/code-review - single - no PRD; review diff vs develop` |
| Multi-angle subset | `/code-review - multi-angle - ângulos: qualidade, segurança` |

If PRD/PLAN are omitted, the agent still **searches** `features/**/PRD` and `features/**/PLAN` (repo + global). It asks you **once** only when zero or multiple ambiguous pairs remain.

**Discovery globs (step 0.5):**

| Location | Patterns |
|----------|----------|
| Workspace | `features/**/PRD/*.md`, `features/**/PLAN/PLAN_*.md` (also `docs/features/**` if used) |
| Global | `~/.cursor/sdd/<repo-id>/features/**/PRD/*.md`, `.../features/**/PLAN/PLAN_*.md` |

---

## Step-by-step

1. Finish implementation on a **feature branch** ([01](01-sdd-workflow.md) or [02](02-developer.md)).
2. Invoke **`/code-review`** (optionally with `single` / `multi-angle`, base branch, or PRD/PLAN paths).
3. If mode was omitted: answer the ask (1 single / 2 multi-ângulo) before the agent continues.
4. Agent confirms repo, stack (.NET, etc.), and **resolves SDD artifacts** under `features/` (manifest + globs).
5. Agent scopes the diff: `git diff <base>...<head>`, file list, recent commits.
6. **SDD traceability** (when PRD/PLAN found): PLAN step status vs code, PRD acceptance criteria vs tests.
7. **Standards review**: project docs, `dotnet-guidelines` for .NET, principles cheatsheet when relevant.
8. **Code analysis** across correctness, architecture, tests, security, performance, maintainability. Multi-angle may spawn parallel Task reviewers (qualidade / aceite / segurança).
9. **Verification** when feasible: `dotnet build`, `dotnet test`; optional `/test-coverage` if PRD/PLAN or you set a threshold (default **80%** on changed production files).
10. Agent writes the **report** with tiers and decision.
11. Address **Changes required** with `developer`, `sdd-develop`, or manual edits; re-run review if needed.

**Report structure you should expect:**

| Section | Content |
|---------|---------|
| Critical | Must fix before merge (bugs, security, PRD gaps, failing build/tests) |
| Important | Should fix; PLAN/PRD drift, missing tests, architecture leaks |
| Nice-to-have | Style, minor refactors, optional improvements |
| Decision | Approved / Approved with reservations / Changes required |
| Positives | What was done well |

Chat language for the report may be **pt-BR** (per your user-language rule); technical terms and paths stay in English.

---

## Minimal example

Scenario: after SDD Step 2 on branch `feature/signup-validation` in `my-api`.

```
You: /code-review - base main

Agent: Modo de code-review?
       1) single
       2) multi-ângulo

You: 1

Agent: [finds features/001-signup-email-validation/US01/PRD/001_signup_email_validation.md
        and .../PLAN/PLAN_001_... under features/]
       [diff vs main: 4 files]
       [runs dotnet build && dotnet test]

Agent: ## Review - Approved with reservations

       Critical: (none)

       Important:
       - src/Api/Controllers/SignupController.cs:42 - invalid email returns 500;
         PRD requires 400 with validation message.

       Nice-to-have:
       - Extract duplicate email regex to shared constant.

       SDD: PLAN Step 2 marked complete; Step 3 still pending - OK for this diff.

       Decision: Approved with reservations - fix Important before commit.

You: [fix controller] /developer - return 400 for invalid email per PRD

You: /commit
```

---

## Common mistakes

1. **Reviewing without SDD context when it exists** - If you used `sdd-spec` / `sdd-plan` / `sdd-develop`, invoke review **on the same repo** so the agent can find PRD/PLAN under `features/`. Do not assume artifacts are missing because they are gitignored; they may be under `~/.cursor/sdd/<repo-id>/features/`.

2. **Ignoring PRD acceptance criteria** - A green build is not enough. The report maps **CA** from the PRD to code and tests; skipping that section leads to merged features that miss requirements.

3. **No valid feature branch before commit** - Review on `main` / `develop` or with dirty unrelated changes confuses scope. Checkout `feature/<slug>`, commit only review scope, then `/commit` ([05 - operational skills](05-operational-skills.md)).

4. **Treating review as implementation** - `code-review` does not write PRD/PLAN or large fixes by default. Use **`/sdd-develop`**, **`developer`**, or manual edits for changes, then review again.

5. **Skipping build/test verification** - Ask the agent to run `dotnet build` / `dotnet test` when local environment allows; otherwise note limitations in the report and run them yourself before merge.

6. **Confusing with `test-coverage`** - Coverage is a **metric report** ([04 - test-coverage](04-test-coverage.md)). Code review may **reference** coverage when PRD/PLAN sets a threshold, but it is not a substitute for the full post-code sequence in [README.md](README.md).

7. **Expecting a silent single/multi default** - Bare `/code-review` always asks. Pass `- single` or `- multi-angle` to skip the question.

---

## Next step

| After review | Do this |
|--------------|---------|
| **Approved** or reservations fixed | `/test-coverage` - [04 - test-coverage](04-test-coverage.md) (.NET with tests) |
| Ready to land | `/commit` - [05 - operational skills](05-operational-skills.md) |
| **Changes required** | Fix via [02 - developer](02-developer.md) or `/sdd-develop - <plan-path> - Step N` |
| Findings need new feature scope | `/sdd-spec` - [01 - SDD workflow](01-sdd-workflow.md) |
| Coverage below threshold | `/test-coverage` -> fix tests -> re-run review |
| Open PR (optional) | User opens PR in GitHub web UI after approval; not automatic |
| Back to skill map | [Guides README](README.md) |

**Typical post-code order:** `code-review` -> `test-coverage` -> `commit` (see [README - Post-code workflow](README.md#post-code-workflow)).
