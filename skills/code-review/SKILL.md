---
name: code-review
description: Review a branch or diff against PRD/PLAN acceptance, project standards, and shared guidelines. Asks single vs multi-angle when not specified. Produces a structured report (critical, important, nice-to-have). Use when the user says "use skill code-review", "review this PR", or "/code-review". Git-only - optional GitHub PR via gh CLI.
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
[ ] PIPELINE.md read (SDD/speckit skills only)
[ ] User confirmed current action (sim)
-> If any unchecked: STOP
```

---

## Trigger

Invoke when the user asks for: `use skill code-review`, `review this PR`, `code review`, or `/code-review`.

**Review mode (mandatory choice - no silent default):**

| Mode | Explicit invoke examples |
|------|--------------------------|
| **Single** | `single`, `single-angle`, `simples` |
| **Multi-angle** | `multi-angle`, `multi-ângulo`, or `ângulos: qualidade, aceite, segurança` (subset allowed) |

If the invocation does **not** name single **or** multi-angle: **STOP** after gate check (-1) / before deep diff analysis - ask once **(pt-BR)** and wait. Do **not** assume single. Do **not** assume multi.

```text
Modo de code-review?
1) single - um revisor (passos -1..8)
2) multi-ângulo - qualidade + aceite + segurança (ou diga o subset)
```

## Outcome

A structured **review report** with severity tiers (critical / important / nice-to-have) and a clear decision: **Approved**, **Approved with reservations**, or **Changes required**. Write the report in **pt-BR** in chat-aligned reviews (technical terms may stay in English). Does not modify code unless the user asks for fixes in a follow-up.

## Required input

| Input | Rule |
|-------|------|
| Base branch | `main`, `develop` - ask once if missing |
| Feature branch | Current branch or named branch |
| PRD / PLAN (SDD) | Optional in invocation; **resolve in step 0.5** if omitted (see `reference.md` section SDD artifact resolution) |
| Review mode | Explicit in invoke **or** answer to step 0.25 - never silent default |

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
| Caveman Mode (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` - **Full mode** |
| Final Git hygiene | `~/.cursor/skills/_shared/developer-common/step-7-checklist.md` |
| Report template | `reference.md` (this skill) |

Prefer project `docs/standards/` or repo `AGENTS.md` over generic guidelines when both exist.

Do **not** preload `code-guidelines/languages/**` or corporate static-analysis workflows.

## Process

### -1. Caveman Mode

Check `~/.cursor/sdd/preferences.json`:
- If file missing -> create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` -> load `~/.cursor/skills/_shared/caveman/CAVEMAN.md` (Full mode rules) and display:
  > Modo Caveman ativo (respostas compactas). Digite `caveman off` a qualquer momento para desativar.
- Honor `caveman on` / `caveman off` commands from the user at any point during the session.

### 0. Workspace

Confirm target repo (not `cursor-dev-toolkit` unless that is the subject). Detect stack (`*.sln` -> .NET; `angular.json` -> Angular). Read `AGENTS.md` / `README.md`. Load dotnet-guidelines only for .NET reviews.

### 0.25 Review mode (single vs multi-angle)

Resolve mode from the invocation **or** from the user's answer to the Trigger prompt.

| Signal in invoke / reply | Mode |
|--------------------------|------|
| `single` / `single-angle` / `simples` / `1` | Single reviewer (steps -1..8 only) |
| `multi-angle` / `multi-ângulo` / `2` / named `ângulos: …` | Multi-angle (see section below) |

If still unset: **STOP** - ask the Trigger prompt **(pt-BR)** - do not continue to 0.5/1 until answered. Novice-friendly: never pick a default for them.

### 0.5 Resolve SDD artifacts

Load `STORAGE.md`. Follow **`reference.md` section SDD artifact resolution** (manifest, globs repo + `~/.cursor/sdd/<repo-id>/`, pair by `NNN`). Use full paths in the report. If one PRD/PLAN pair -> read both before the diff review. If none after a full search -> note **SDD limitation** in the report (technical review only). If ambiguous -> ask once in pt-BR with numbered options.

### 1. Scope the diff

```bash
git fetch origin  # when remote comparison is needed
git diff <base>...<head> --stat
git diff <base>...<head>
git log <base>..<head> --oneline
```

Default `<head>` to current branch. List files; confirm with user before deep review if the set is large.

### 2. SDD traceability (when artifacts found or user provided)

Skip this section only when step 0.5 found no PRD/PLAN (document limitation - do not claim artifacts do not exist).

- PLAN progress bar and step statuses match completed work
- Each **Completed** / **Concluido** step has deliverables checked; no **Pending** steps with code already merged
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
| Architecture | Layer boundaries, DI, no domain -> infrastructure leaks |
| Tests | Behavior covered; meaningful assertions; no trivial tests |
| Security | Secrets, injection, authz, sensitive logs |
| Performance | N+1, unbounded work, missing async where I/O |
| Maintainability | Naming, method size, duplication; magic values / structure - see `csharp-patterns.md` normative sections |

Use the checklists in `reference.md` - do not paste full guideline bodies into the report.

### 5. Run verification (when feasible)

| Stack | Commands |
|-------|----------|
| .NET | `dotnet build`, `dotnet test` (scoped if large) |
| .NET coverage | `use skill test-coverage` when PRD, PLAN, or user sets a coverage target (default threshold **80%** on changed production files) |
| Node | `npm run build`, `npm test` per project scripts |

For .NET with a coverage target: run `test-coverage` before final decision; paste the summary into the report section Testes (see `reference.md`). If `test-coverage` reports **Fail** (< threshold), treat as **Changes required** unless the user documents an accepted exception.

Record pass/fail in the report. Missing local run -> note as limitation.

### 6. Decision

| Decision | When |
|----------|------|
| **Approved** | PRD/PLAN met; no critical issues; tests/build green; coverage >= threshold when target applies |
| **Approved with reservations** | Minor gaps; no security/correctness blockers; coverage at or above threshold with documented gaps below 100% target |
| **Changes required** | Critical bugs/security; PRD gaps; build/test failures; coverage < threshold on changed files when target applies |

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

## Multi-angle mode (when chosen)

Run **only** after step **0.25** resolved to multi-angle (explicit flag **or** user chose option 2 / named angles). Single mode = steps -1..8 as one reviewer - never implied by silence.

When multi-angle:

1. After scoping the diff (step 1) and resolving SDD artifacts (0.5), spawn up to **3 parallel Task** subagents - one per requested angle (default all three if user said multi without subset):
   - **quality** - correctness, architecture, tests, maintainability, performance
   - **acceptance (aceite)** - PRD criteria / PLAN deliverables vs the diff
   - **security** - AuthZ/AuthN, injection, secrets/PII, dangerous defaults (hints: `_shared/agents/prompts/security.md`)
2. Parent synthesizes Task outputs into **one** report using the existing `reference.md` template (map findings to críticos / importantes / nice-to-have).
3. Decision matrix (step 6) and coverage gates are unchanged - multi-angle does **not** change decision semantics, does **not** auto-block O3 or the SDD pipeline, and does **not** require separate blind-reviewer skills.

See `reference.md` section **Multi-angle mode** for invoke examples and per-angle checklists.

## Must not

- Write or update PRD/PLAN files (hand off to `use skill sdd-spec` / `use skill sdd-plan`)
- Auto-merge, auto-approve, or rewrite code without user request
- Work-item tracker APIs, external PR platform APIs, or obsolete guideline paths
- Block on coverage only when no target applies - when PRD, PLAN, user, or a `test-coverage` report defines a threshold (default **80%** on changed production files), treat below threshold as **Changes required**
- Paste entire guideline files into the review output
- Claim no PRD/PLAN or skip step 0.5 / SDD traceability without searching all locations in `STORAGE.md`
- Assume **single** or **multi-angle** when the user did not name either (always ask - step 0.25)
- Force multi-angle as a pipeline gate, or create separate mandatory blind-reviewer skills
- **AI co-author trailers** - in any form. Under NO circumstances should you include `Co-authored-by: Cursor <cursoragent@cursor.com>`, `Co-authored-by: Antigravity`, or any other AI agent attribution in commit messages or PR descriptions.

## Handoff

| Situation | Next |
|-----------|------|
| After O3 (`orchestrate-develop`) completes | `use skill code-review` - skill asks single vs multi if not specified; never required as pipeline gate |
| New feature / PRD from review findings | `use skill sdd-spec` - paste or summarize review items; do **not** write PRD in this skill |
| Coverage below threshold | `use skill test-coverage` -> then `use skill dotnet-developer` or `use skill sdd-develop` |
| Fixes needed | User or `use skill sdd-develop` / `use skill dotnet-developer` |
| Commit fixes | `use skill commit` |
| All SDD steps done + approved | User runs `gh pr create` or merges per repo policy |
