# developer shortcut

**Index:** [Guides README](README.md)

---

## What it is

**`developer`** is the toolkit shortcut for **small-to-medium .NET work** without a full SDD cycle (no PRD or PLAN required). You describe the change in chat; the agent loads Clean Architecture and C# guidelines on demand, works on a feature branch, runs `dotnet build` / `dotnet test`, and hands off to `commit` or `code-review`.

Use it when the [decision tree in README.md](README.md) points to the right branch for isolated .NET fixes-not when the change needs multi-step planning across the codebase.

---

## When to use / when not to use

### Use `developer` when

- The bug or refactor is **isolated to one area** (single handler, repository, endpoint, or test file).
- **Low complexity** - you can describe acceptance in a few sentences; no PRD needed.
- The repo already has patterns to follow (Glob/Read similar code).
- You want code + tests in **one or a few chat sessions**, not a formal PLAN.

**Examples:** fix null reference in a validator; add a field to a DTO and map it; correct a failing unit test; small refactor matching existing architecture.

### Do not use `developer` when

- The work needs **EF migrations**, new schema, or broad data changes.
- **Multiple bounded contexts** or **3+ layers** touched with new design (Domain + Application + Infrastructure + API).
- **Cross-cutting feature** - messaging, new external integrations, or 10+ files / ~4+ hours estimated.
- You already have an approved **PLAN** -> use [01 - SDD workflow](01-sdd-workflow.md): `use skill sdd-develop - <plan-path> - Step N`.
- **`dotnet build` or tests are already red** and you only need to diagnose CI/local failures -> use `use skill fix-build` ([05 - operational skills](05-operational-skills.md)), not this skill.

**Rule of thumb:** if **two or more** SDD signals apply (migration, multi-repo, large scope, existing PLAN), switch to [01 - SDD workflow](01-sdd-workflow.md).

| Signal | Prefer SDD (`spec` -> `plan` -> `sdd-develop`) |
|--------|---------------------------------------------|
| Database / migrations | Yes |
| Multiple services or repos | Yes |
| New integration or consumer | Yes |
| 10+ files or 4+ hours | Yes |
| Approved PLAN exists | Use `sdd-develop`, not `developer` |
| Single-area bugfix | **`developer`** |

---

## Prerequisites

1. **Toolkit installed** - skills under `~/.cursor/skills/` after [Install](../INSTALL.md) and `scripts/sync-cursor.ps1`.
2. **.NET repo open in Cursor** - solution or project with `*.sln` / `*.csproj`.
3. **Agent mode** - the skill writes and edits code.
4. **Feature branch** - agent creates or uses `feature/<slug>` or `feat/<id>`; never commits on `main`, `master`, or `develop`.
5. **Clear acceptance** - state what should happen after the change (from issue text, user description, or a short bullet list). No PRD file required.

The agent loads `dotnet-guidelines` and developer-common steps from `~/.cursor/skills/_shared/` only when needed-it does not paste full guideline bodies into chat.

---

## How to invoke

Primary invoke (same as [AGENTS.md](../../AGENTS.md)):

```
use skill developer
```

Alternatives the agent recognizes: `dotnet fix`, `implement .NET feature` (for small scope only).

**Include in the same message (recommended):**

- What is wrong or missing today.
- Expected behavior after the fix.
- Optional: file names, test names, or error messages.

**Example:**

```
use skill developer - OrderMapper ignores DiscountPercent on export;
map the field like OrderDto does in the API layer and add a unit test.
```

---

## Step-by-step

1. Open your **.NET project** in Cursor (not the toolkit repo unless that is what you are changing).
2. Ensure you are on or allow the agent to create a **feature branch**.
3. Invoke **`use skill developer`** with a concise description and acceptance criteria.
4. The agent reviews repo context and loads **dotnet-guidelines** for the task scope only.
5. It lists **micro-steps** (3-7 tasks: files, tests) and implements matching existing patterns.
6. It runs **`dotnet build`** and **`dotnet test --no-build`** (or project-scoped equivalents) and fixes failures in scope.
7. Optional pre-commit checks run per shared developer-common steps.
8. **Stop when green.** Hand off to review or commit-do not start unrelated work in the same session if scope grows.

**If scope grows during the session** (migration needed, many layers, new integration), stop and escalate to SDD:

```
use skill sdd-spec - [feature description]
```

Then `use skill sdd-plan - <prd-path>` and `use skill sdd-develop - <plan-path> - Step 1` per [01 - SDD workflow](01-sdd-workflow.md).

**Context (~40%):** if the chat is long, pause and offer `use skill commit` before continuing; start a new chat for follow-up work.

---

## Minimal example

Scenario: isolated bug in one validator class in `my-api`.

```
You: use skill developer - CreateUserValidator allows empty email.
     Reject empty email with the same message pattern as PhoneValidator.

Agent: [reads PhoneValidator and CreateUserValidator, confirms feature branch]
       [adds rule + unit test Should_FailValidation_When_EmailIsEmpty]

Agent: dotnet build && dotnet test - passed.
       Handoff: use skill code-review or use skill commit

You: use skill code-review
```

No PRD, no PLAN-one invoke, one focused change, build and tests green.

---

## Common mistakes

1. **Skipping PRD on a large feature** - Using `developer` for a multi-layer feature or migration leads to incomplete design and huge diffs. When two or more SDD signals apply, switch to [01 - SDD workflow](01-sdd-workflow.md) before coding.

2. **Not running build/tests** - Assuming the change is trivial without `dotnet build` / `dotnet test` ships regressions. The skill expects green build and tests in scope; you should verify before commit.

3. **Confusing with `fix-build`** - `fix-build` diagnoses **existing** build or test failures (often CI or broken mainline). `developer` **implements** a described change. If the repo already fails to compile, invoke `use skill fix-build` first ([05 - operational skills](05-operational-skills.md)).

4. **Working on `main` / `develop`** - Commits on integration branches violate branch rules. Confirm the agent checked out `feature/<slug>` before review or commit.

5. **Continuing after scope explosion** - Adding “while you’re here, also add caching and a new endpoint” in the same session. Stop, split work, or escalate to `spec` -> `plan` -> `sdd-develop`.

6. **Using `developer` when a PLAN exists** - If you already have `PLAN/PLAN_NNN_*.md`, use `use skill sdd-develop - <plan-path> - Step N` so progress stays on the PLAN checklist.

---

## Next step

| After | Do this |
|-------|---------|
| Code change complete | `use skill code-review` - [03 - code-review](03-code-review.md) |
| .NET project with tests | `use skill test-coverage` - [04 - test-coverage](04-test-coverage.md) |
| Ready to land | `use skill commit` - [05 - operational skills](05-operational-skills.md) |
| Scope was bigger than expected | [01 - SDD workflow](01-sdd-workflow.md) - `use skill sdd-spec` |
| Build still failing | `use skill fix-build` - [05 - operational skills](05-operational-skills.md) |
| Back to skill map | [Guides README](README.md) |

**Compare paths:** re-read the [decision tree](README.md#which-skill-should-i-use) if you are unsure between this shortcut and SDD (CT3).
