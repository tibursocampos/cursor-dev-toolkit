# test-coverage

**Index:** [Guides README](README.md)

---

## What it is

**`test-coverage`** runs **.NET test coverage** using **Coverlet** and **ReportGenerator**, then produces a structured report aligned with common SonarQube-style views:

- **New code** — line coverage on **changed production `.cs` files** vs a base branch
- **Overall branch** — solution-wide line coverage after tests
- **Per-file** — line % for each changed production file

The skill evaluates against a **threshold** (default **80%** on new code) and returns **Pass** or **Fail** with a gap list. It does **not** require a SonarQube server, SonarLint, or corporate pipeline APIs.

Use it in the **post-code workflow** after [code-review](03-code-review.md) and before [commit](05-operational-skills.md) when your .NET project has tests.

> **Note:** The **cursor-dev-toolkit** repo itself has no .NET test projects—run this skill in your **application repo**, not when documenting the toolkit.

---

## When to use / when not to use

### Use `test-coverage` when

- You have a **.NET solution** with test projects (`*Tests.csproj` / `*.Tests.csproj`).
- You finished implementation ([01 — SDD](01-sdd-workflow.md) or [02 — dotnet-developer](02-dotnet-developer.md)) and want **evidence before commit**.
- PRD, PLAN, or [code-review](03-code-review.md) mentions a coverage target (default **80%** on changed production files).
- You need **on-disk artifacts** under `TestResults/` (`Summary.txt`, `index.html`, Cobertura XML) for your own records or PR description.

### Do not use `test-coverage` when

- The repo has **no tests** or **no Coverlet** — add `coverlet.collector` and tests first (see Prerequisites).
- **`dotnet build` or `dotnet test` already fails** → `use skill fix-build` ([05 — operational skills](05-operational-skills.md)).
- You only want a **code quality review** without metrics → [03 — code-review](03-code-review.md).
- You are working **only in cursor-dev-toolkit** (Markdown docs)—coverage does not apply to this feature’s deliverables.

---

## Prerequisites

1. **Toolkit installed** — [Install](../INSTALL.md) and `scripts/sync-cursor.ps1`.
2. **Consumer .NET repo open in Cursor** — `*.sln` or at least one test `*.csproj`.
3. **Agent mode** — the skill runs `dotnet test` and ReportGenerator in the shell.
4. **Coverlet on test project(s)** — `coverlet.collector` package reference; agent stops with install steps if missing.
5. **`dotnet test` passes** before coverage collection.
6. **ReportGenerator** — global tool (`dotnet tool install -g dotnet-reportgenerator-globaltool`); agent installs once if needed.
7. **Base branch** — usually `main` or `develop` for “new code” diff; tell the agent if yours differs.
8. **Feature branch** — same as other post-code skills (`feature/<slug>` or `feat/<id>`).

Detailed commands and exclusions (migrations, generated files): `~/.cursor/skills/test-coverage/reference.md` after sync—not duplicated here.

---

## How to invoke

Primary invoke:

```
use skill test-coverage
```

Alternatives: `coverage report`, `/coverage`.

**Optional parameters** (same message):

| Parameter | Example | Default |
|-----------|---------|---------|
| Base branch | `use skill test-coverage — base develop` | `main` or `develop` (agent asks once if ambiguous) |
| Test project | `use skill test-coverage — tests src/MyApp.Tests/MyApp.Tests.csproj` | Auto-detect `*Tests.csproj` |
| Threshold | `use skill test-coverage — threshold 85` | **80** (% line coverage on changed production files) |
| Target (aspirational) | `use skill test-coverage — target 100` | **100** — report notes gaps below 100 even when Pass |

**Example:**

```
use skill test-coverage — base main — threshold 80
```

---

## Step-by-step

1. Complete code changes on a **feature branch**; [code-review](03-code-review.md) optional but recommended first.
2. Open your **.NET application repo** in Cursor (not toolkit-only workspace).
3. Invoke **`use skill test-coverage`** with optional base branch, test path, or threshold.
4. Agent resolves **changed production `.cs` files** vs base (`git diff <base>...HEAD`).
5. Agent verifies **Coverlet**, green **`dotnet test`**, and **ReportGenerator**.
6. Agent runs **`dotnet test`** with coverage → `TestResults/**/coverage.cobertura.xml`.
7. Agent runs **ReportGenerator** → `TestResults/CoverageReport/` (`Summary.txt`, `index.html`).
8. Agent computes **new code**, **overall branch**, and **per-file** metrics (excludes migrations, `*.g.cs`, test projects from new-code denominator).
9. Agent reports **Pass** (≥ threshold) or **Fail** (&lt; threshold) with gap list and paths to on-disk reports.
10. If **Fail**, add tests via [dotnet-developer](02-dotnet-developer.md) or `use skill implement`, then re-run this skill.

**How to read the report:**

| Metric | Meaning |
|--------|---------|
| **New code** | Weighted line % on production files you changed vs base—this drives Pass/Fail |
| **Overall branch** | Whole solution/assemblies after test run—context, not always the gate |
| **Per-file** | Each changed file’s line %; use to prioritize test additions |
| **Target 100%** | Aspirational; agent lists files below 100% even when threshold Pass |

Chat report is often **pt-BR**; paths and commands stay in English. Agent must cite workspace paths under `TestResults/`—not chat-only claims.

---

## Minimal example

Scenario: branch `feature/order-discount` in `my-api`, base `main`, threshold 80%.

```
You: use skill test-coverage — base main

Agent: [diff: 3 production files changed]
       [dotnet test + ReportGenerator]
       [reads TestResults/CoverageReport/Summary.txt]

Agent: ## Coverage — Pass (threshold 80%)

       New code: 87.2% (3 files)
       Overall branch: 74.1%

       Per-file:
       - src/Application/Orders/ApplyDiscountHandler.cs — 92%
       - src/Domain/Orders/DiscountRules.cs — 81%
       - src/Infrastructure/Orders/OrderRepository.cs — 78%  ← below target 100%

       Artifacts:
       - TestResults/CoverageReport/Summary.txt
       - TestResults/CoverageReport/index.html

       Handoff: use skill commit

You: use skill commit
```

If new code were **72%**, decision would be **Fail** → add tests → re-run `use skill test-coverage`.

---

## Common mistakes

1. **Running in a repo without Coverlet** — Coverage collection fails or is empty. Ensure `coverlet.collector` on test projects before invoking; follow agent install instructions if missing.

2. **Assuming SonarQube server is required** — This skill uses **local Coverlet + ReportGenerator** only. Metrics are *aligned* with Sonar-style “new code” thinking; no Sonar login or server needed.

3. **Skipping coverage before commit** — Post-code order is `code-review` → **`test-coverage`** → `commit` ([README](README.md#post-code-workflow)). Committing without checking changed-file coverage often misses regressions on new logic.

4. **Opening cursor-dev-toolkit only** — No `*Tests.csproj` here. Open the **app repo** you are building; the agent stops if the workspace has no test projects.

5. **Treating overall branch % as the gate** — **Pass/Fail** uses **new code** on changed production files vs threshold (default 80%). Overall solution coverage can be lower and still Pass.

6. **Ignoring Fail after code-review Approved** — [code-review](03-code-review.md) may require coverage ≥ threshold when PRD/PLAN sets one. Fix tests first (`dotnet-developer` / `implement`), re-run coverage, then commit.

---

## Next step

| After coverage | Do this |
|----------------|---------|
| **Pass** | `use skill commit` — [05 — operational skills](05-operational-skills.md) |
| **Pass** + PR policy | Paste approval block / `Summary.txt` into PR description |
| **Fail** — add tests | [02 — dotnet-developer](02-dotnet-developer.md) or `use skill implement — <plan-path> — Step N` |
| **Fail** — build/tests broken | `use skill fix-build` — [05 — operational skills](05-operational-skills.md) |
| Re-validate quality | `use skill code-review` — [03 — code-review](03-code-review.md) |
| Back to skill map | [Guides README](README.md) |

**Typical sequence:** [03-code-review](03-code-review.md) → **test-coverage** → `commit`.
