# code-review

**Index:** [Guides README](README.md)

---

## What it is

**`code-review`** runs a structured review of your **branch or diff** against project standards, optional **PRD/PLAN** acceptance criteria, and shared guidelines (Clean Architecture, tests, security). The agent produces a report with severity tiers and a decision: **Approved**, **Approved with reservations**, or **Changes required**.

The skill **does not modify code** unless you ask for fixes in a follow-up. It is the recommended step **after** [SDD implement](01-sdd-workflow.md) or [dotnet-developer](02-dotnet-developer.md) and **before** [commit](05-operational-skills.md) or merge.

---

## When to use / when not to use

### Use `code-review` when

- Implementation is **done** on a feature branch and you want a pre-commit or pre-PR gate.
- You followed **SDD** or **`dotnet-developer`** and need traceability to PRD acceptance criteria or PLAN steps.
- You want a second pass on **correctness, architecture, tests, security**, and maintainability.
- You need a clear **go / no-go** before `use skill commit` or opening a pull request.

PRD and PLAN paths are **optional** in your invoke—the agent searches repo `PRD/` / `PLAN/` and global `~/.cursor/sdd/<repo-id>/` per storage rules before asking you.

### Do not use `code-review` when

- You have **not written code yet** — use [01 — SDD workflow](01-sdd-workflow.md) or [02 — dotnet-developer](02-dotnet-developer.md) first.
- The repo **does not build or tests fail** and you only need to fix failures → `use skill fix-build` ([05 — operational skills](05-operational-skills.md)).
- You want **coverage metrics only** → `use skill test-coverage` ([04 — test-coverage](04-test-coverage.md)); run review after or combine in the post-code sequence from [README.md](README.md).

---

## Prerequisites

1. **Toolkit installed** — [Install](../INSTALL.md) and `scripts/sync-cursor.ps1`.
2. **Target project open in Cursor** — the repo under review.
3. **Git state** — changes on a **feature branch** (`feature/<slug>` or `feat/<id>`), not uncommitted work you do not intend to review (or say so explicitly).
4. **Base branch known** — usually `main` or `develop`; tell the agent if your repo uses another default.
5. **Optional SDD artifacts** — if you used SDD, PRD/PLAN may live in:
   - Repo: `PRD/`, `PLAN/` (often gitignored), or
   - Global: `~/.cursor/sdd/<repo-id>/PRD/` and `.../PLAN/`

Storage summary: see [Install](../INSTALL.md) and `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` (after sync). The agent resolves paths via manifest and globs—you do not need to paste full pipeline docs into chat.

---

## How to invoke

Primary invoke:

```
use skill code-review
```

Alternatives: `review this PR`, `/code-review`.

**Variants (add detail in the same message):**

| Goal | Example invoke |
|------|----------------|
| Default (current branch vs base) | `use skill code-review` |
| Named branches | `use skill code-review — compare feature/order-export against main` |
| Explicit SDD paths | `use skill code-review — PRD/001_order_export.md PLAN/PLAN_001_order_export.md` |
| Global SDD storage | `use skill code-review — ~/.cursor/sdd/<repo-id>/PRD/001_*.md` |
| Quick review (no SDD) | `use skill code-review — no PRD; review diff vs develop` |

If PRD/PLAN are omitted, the agent still **searches** repo and global storage (step 0.5). It asks you **once** only when zero or multiple ambiguous pairs remain.

---

## Step-by-step

1. Finish implementation on a **feature branch** ([01](01-sdd-workflow.md) or [02](02-dotnet-developer.md)).
2. Invoke **`use skill code-review`** (with base branch or PRD/PLAN paths if helpful).
3. Agent confirms repo, stack (.NET, etc.), and **resolves SDD artifacts** (manifest + globs).
4. Agent scopes the diff: `git diff <base>...<head>`, file list, recent commits.
5. **SDD traceability** (when PRD/PLAN found): PLAN step status vs code, PRD acceptance criteria vs tests.
6. **Standards review**: project docs, `dotnet-guidelines` for .NET, principles cheatsheet when relevant.
7. **Code analysis** across correctness, architecture, tests, security, performance, maintainability.
8. **Verification** when feasible: `dotnet build`, `dotnet test`; optional `use skill test-coverage` if PRD/PLAN or you set a threshold (default **80%** on changed production files).
9. Agent writes the **report** with tiers and decision.
10. Address **Changes required** with `dotnet-developer`, `implement`, or manual edits; re-run review if needed.

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
You: use skill code-review — base main

Agent: [finds PRD/001_signup_email_validation.md and PLAN/PLAN_001_... in repo]
       [diff vs main: 4 files]
       [runs dotnet build && dotnet test]

Agent: ## Review — Approved with reservations

       Critical: (none)

       Important:
       - src/Api/Controllers/SignupController.cs:42 — invalid email returns 500;
         PRD requires 400 with validation message.

       Nice-to-have:
       - Extract duplicate email regex to shared constant.

       SDD: PLAN Step 2 marked complete; Step 3 still pending — OK for this diff.

       Decision: Approved with reservations — fix Important before commit.

You: [fix controller] use skill dotnet-developer — return 400 for invalid email per PRD

You: use skill commit
```

---

## Common mistakes

1. **Reviewing without SDD context when it exists** — If you used `spec` / `plan` / `implement`, invoke review **on the same repo** so the agent can find PRD/PLAN. Do not assume artifacts are missing because they are gitignored; they may be under `~/.cursor/sdd/<repo-id>/`.

2. **Ignoring PRD acceptance criteria** — A green build is not enough. The report maps **CA** from the PRD to code and tests; skipping that section leads to merged features that miss requirements.

3. **No valid feature branch before commit** — Review on `main` / `develop` or with dirty unrelated changes confuses scope. Checkout `feature/<slug>`, commit only review scope, then `use skill commit` ([05 — operational skills](05-operational-skills.md)).

4. **Treating review as implementation** — `code-review` does not write PRD/PLAN or large fixes by default. Use **`use skill implement`**, **`dotnet-developer`**, or manual edits for changes, then review again.

5. **Skipping build/test verification** — Ask the agent to run `dotnet build` / `dotnet test` when local environment allows; otherwise note limitations in the report and run them yourself before merge.

6. **Confusing with `test-coverage`** — Coverage is a **metric report** ([04 — test-coverage](04-test-coverage.md)). Code review may **reference** coverage when PRD/PLAN sets a threshold, but it is not a substitute for the full post-code sequence in [README.md](README.md).

---

## Next step

| After review | Do this |
|--------------|---------|
| **Approved** or reservations fixed | `use skill test-coverage` — [04 — test-coverage](04-test-coverage.md) (.NET with tests) |
| Ready to land | `use skill commit` — [05 — operational skills](05-operational-skills.md) |
| **Changes required** | Fix via [02 — dotnet-developer](02-dotnet-developer.md) or `use skill implement — <plan-path> — Step N` |
| Findings need new feature scope | `use skill spec` — [01 — SDD workflow](01-sdd-workflow.md) |
| Coverage below threshold | `use skill test-coverage` → fix tests → re-run review |
| Open PR (optional) | User-driven `gh pr create` after approval; not automatic |
| Back to skill map | [Guides README](README.md) |

**Typical post-code order:** `code-review` → `test-coverage` → `commit` (see [README — Post-code workflow](README.md#post-code-workflow)).
