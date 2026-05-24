---
name: code-review
description: Review a branch or diff against PRD/PLAN acceptance, project standards, and shared guidelines. Produces a structured report (critical, important, nice-to-have). Use when the user says "use skill code-review", "review this PR", or "/code-review". Git-only — optional GitHub PR via gh CLI.
---

# Skill: code-review

## Trigger

Invoke when the user asks for: `use skill code-review`, `review this PR`, `code review`, or `/code-review`.

## Outcome

A structured **review report** in English with severity tiers (critical / important / nice-to-have) and a clear decision: **Approved**, **Approved with reservations**, or **Changes required**. Does not modify code unless the user asks for fixes in a follow-up.

## Required input

Ask once if missing:

| Input | Example |
|-------|---------|
| Base branch | `main`, `develop` |
| Feature branch | current branch or named branch |
| PRD path (SDD) | `PRD/002_feature.md` |
| PLAN path (SDD) | `PLAN/PLAN_002_feature.md` |

For a quick local review (single commit or file list), base branch + changed paths may suffice.

## Lazy-load (only when needed)

| When | Path (after sync) |
|------|-------------------|
| Repo context | `~/.cursor/skills/_shared/developer-common/step-0-context.md` |
| Before code analysis (.NET) | `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md`, `csharp-patterns.md` |
| Pre-PR gate (.NET) | `~/.cursor/skills/_shared/dotnet-guidelines/checklist.md` |
| Principles | `~/.cursor/skills/_shared/code-guidelines/principles/principles-cheatsheet.md` |
| Final Git hygiene | `~/.cursor/skills/_shared/developer-common/step-7-checklist.md` |
| Report template | `reference.md` (this skill) |

Prefer project `docs/standards/` or repo `AGENTS.md` over generic guidelines when both exist.

Do **not** preload `code-guidelines/languages/**` or corporate static-analysis workflows.

## Process

### 0. Workspace

Confirm target repo. Detect stack (`*.sln` → .NET; `angular.json` → Angular). Read `AGENTS.md` / `README.md`. Load dotnet-guidelines only for .NET reviews.

### 1. Scope the diff

```bash
git fetch origin  # when remote comparison is needed
git diff <base>...<head> --stat
git diff <base>...<head>
git log <base>..<head> --oneline
```

Default `<head>` to current branch. List files; confirm with user before deep review if the set is large.

### 2. SDD traceability (when PRD/PLAN provided)

- PLAN progress bar and step statuses match completed work
- Each **Completed** step has deliverables checked; no **Pending** steps with code already merged
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
| Node | `npm run build`, `npm test` per project scripts |

Record pass/fail in the report. Missing local run → note as limitation.

### 6. Decision

| Decision | When |
|----------|------|
| **Approved** | PRD/PLAN met; no critical issues; tests/build green |
| **Approved with reservations** | Minor gaps; no security/correctness blockers |
| **Changes required** | Critical bugs/security; PRD gaps; build/test failures |

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

- Auto-merge, auto-approve, or rewrite code without user request
- Work-item tracker APIs, external PR platform APIs, or obsolete guideline paths
- Block on optional coverage targets unless the user or PRD sets them
- Paste entire guideline files into the review output

## Handoff

| Situation | Next |
|-----------|------|
| Fixes needed | User or `use skill implement` / `use skill dotnet-developer` |
| Commit fixes | `use skill commit` |
| All SDD steps done + approved | User runs `gh pr create` or merges per repo policy |
