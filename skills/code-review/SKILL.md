---
name: code-review
description: Review a branch or diff against PRD/PLAN acceptance, project standards, and shared guidelines. Produces a structured report (critical, important, nice-to-have). Use when the user says "use skill code-review", "review this PR", or "/code-review". Git-only — optional GitHub PR via gh CLI.
---

# Skill: code-review

## Trigger

Invoke when the user asks for: `use skill code-review`, `review this PR`, `code review`, or `/code-review`.

## Outcome

A structured **review report** with severity tiers (critical / important / nice-to-have) and a clear decision: **Approved**, **Approved with reservations**, or **Changes required**. Write the report in **pt-BR** in chat-aligned reviews (technical terms may stay in English). Does not modify code unless the user asks for fixes in a follow-up.

## Required input

| Input | Rule |
|-------|------|
| Base branch | `main`, `develop` — ask once if missing |
| Feature branch | Current branch or named branch |
| PRD / PLAN (SDD) | Optional in invocation; **resolve in step 0.5** if omitted (see `reference.md` § SDD artifact resolution) |

Ask the user **only after** step 0.5 if zero or multiple PRD/PLAN pairs remain ambiguous. For a quick review without SDD artifacts, base branch + changed paths suffice after 0.5 reports no artifacts.

## Lazy-load (only when needed)

| When | Path (after sync) |
|------|-------------------|
| SDD artifact discovery (step 0.5) | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| Repo context | `~/.cursor/skills/_shared/developer-common/step-0-context.md` |
| Before code analysis (.NET) | `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md`, `csharp-patterns.md` |
| Pre-PR gate (.NET) | `~/.cursor/skills/_shared/dotnet-guidelines/checklist.md` |
| .NET coverage report | `~/.cursor/skills/test-coverage/reference.md` (when PRD/user/PLAN requires coverage) |
| Principles | `~/.cursor/skills/_shared/code-guidelines/principles/principles-cheatsheet.md` |
| Final Git hygiene | `~/.cursor/skills/_shared/developer-common/step-7-checklist.md` |
| Report template | `reference.md` (this skill) |

Prefer project `docs/standards/` or repo `AGENTS.md` over generic guidelines when both exist.

Do **not** preload `code-guidelines/languages/**` or corporate static-analysis workflows.

## Process

### 0. Workspace

Confirm target repo (not `cursor-dev-toolkit` unless that is the subject). Detect stack (`*.sln` → .NET; `angular.json` → Angular). Read `AGENTS.md` / `README.md`. Load dotnet-guidelines only for .NET reviews.

### 0.5 Resolve SDD artifacts

Load `STORAGE.md`. Follow **`reference.md` § SDD artifact resolution** (manifest, globs repo + `~/.cursor/sdd/<repo-id>/`, pair by `NNN`). Use full paths in the report. If one PRD/PLAN pair → read both before the diff review. If none after a full search → note **SDD limitation** in the report (technical review only). If ambiguous → ask once in pt-BR with numbered options.

### 1. Scope the diff

```bash
git fetch origin  # when remote comparison is needed
git diff <base>...<head> --stat
git diff <base>...<head>
git log <base>..<head> --oneline
```

Default `<head>` to current branch. List files; confirm with user before deep review if the set is large.

### 2. SDD traceability (when artifacts found or user provided)

Skip this section only when step 0.5 found no PRD/PLAN (document limitation — do not claim artifacts do not exist).

- PLAN progress bar and step statuses match completed work
- Each **Completed** / **Concluído** step has deliverables checked; no **Pending** steps with code already merged
- PRD acceptance criteria mapped to implementation and tests

Flag PLAN/PRD drift as **important** (not necessarily blocking if scope is otherwise correct).

### 3. Standards and guidelines

1. Project `docs/standards/` or equivalent
2. `~/.cursor/skills/_shared/dotnet-guidelines/` for .NET (layers, tests: xUnit, Moq, FluentAssertions, `Should_<Result>_When_<Condition>`)
3. Principles cheatsheet when installed

### 4. Code analysis

Review changed files for:

| Area | Focus |
|------|--------|
| Correctness | Logic, edge cases, error handling |
| Architecture | Layer boundaries, DI, no domain → infrastructure leaks |
| Tests | Behavior covered; meaningful assertions; no trivial tests |
| Security | Secrets, injection, authz, sensitive logs |
| Performance | N+1, unbounded work, missing async where I/O |
| Maintainability | Naming, method size, duplication, magic values |

Use the checklists in `reference.md` — do not paste full guideline bodies into the report.

### 5. Run verification (when feasible)

| Stack | Commands |
|-------|----------|
| .NET | `dotnet build`, `dotnet test` (scoped if large) |
| .NET coverage | `use skill test-coverage` when PRD, PLAN, or user sets a coverage target (default threshold **80%** on changed production files) |
| Node | `npm run build`, `npm test` per project scripts |

For .NET with a coverage target: run `test-coverage` before final decision; paste the summary into the report § Testes (see `reference.md`). If `test-coverage` reports **Fail** (&lt; threshold), treat as **Changes required** unless the user documents an accepted exception.

Record pass/fail in the report. Missing local run → note as limitation.

### 6. Decision

| Decision | When |
|----------|------|
| **Approved** | PRD/PLAN met; no critical issues; tests/build green; coverage ≥ threshold when target applies |
| **Approved with reservations** | Minor gaps; no security/correctness blockers; coverage at or above threshold with documented gaps below 100% target |
| **Changes required** | Critical bugs/security; PRD gaps; build/test failures; coverage &lt; threshold on changed files when target applies |

### 7. Write report

Use the template in `reference.md` (repo: `skills/code-review/reference.md`; installed: `~/.cursor/skills/code-review/reference.md`).

Be specific: `path:line`, explain **why**, suggest **how** to fix. Include positives.

### 8. Optional PR (user-driven)

Create a PR only when the user asks and review is not **Changes required**:

```bash
gh pr create --base <base> --head "$(git rev-parse --abbrev-ref HEAD)" \
  --title "feat: summary" --body "## Summary\n...\n\n## Test plan\n- [ ] ..."
```

No MCP work-item linking or mandatory corporate PR templates.

## Must not

- Write or update PRD/PLAN files (hand off to `use skill spec` / `use skill plan`)
- Auto-merge, auto-approve, or rewrite code without user request
- Work-item tracker APIs, external PR platform APIs, or obsolete guideline paths
- Block on coverage only when no target applies — when PRD, PLAN, user, or a `test-coverage` report defines a threshold (default **80%** on changed production files), treat below threshold as **Changes required**
- Paste entire guideline files into the review output
- Claim no PRD/PLAN or skip step 0.5 / SDD traceability without searching all locations in `STORAGE.md`

## Handoff

| Situation | Next |
|-----------|------|
| New feature / PRD from review findings | `use skill spec` — paste or summarize review items; do **not** write PRD in this skill |
| Coverage below threshold | `use skill test-coverage` → then `use skill dotnet-developer` or `use skill implement` |
| Fixes needed | User or `use skill implement` / `use skill dotnet-developer` |
| Commit fixes | `use skill commit` |
| All SDD steps done + approved | User runs `gh pr create` or merges per repo policy |
