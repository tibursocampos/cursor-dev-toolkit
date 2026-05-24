# Code review — report template and checklists

Use when writing the final report for the `code-review` skill. Keep the report in **English**. Replace bracketed placeholders.

---

## Report template

```markdown
# Code review — [Feature name]

## Executive summary

**Decision:** Approved | Approved with reservations | Changes required

| Metric | Value |
|--------|-------|
| PRD adherence | [e.g. 4/4 criteria] |
| PLAN status | [e.g. 6/6 steps completed] |
| Files reviewed | [N] |
| Build / tests | [Pass / Fail / Not run] |
| Critical issues | [0] |
| Important issues | [N] |
| Nice-to-have | [N] |

[One short paragraph: scope, main findings, recommendation.]

---

## PLAN verification (SDD)

**PLAN:** [path]

- Progress: [X/N] — [consistent | inconsistencies listed]
- Completed steps: [list]
- Pending / drift: [list or None]

---

## PRD adherence (SDD)

**PRD:** [path]

### Acceptance criteria

| Criterion | Status | Evidence |
|-----------|--------|----------|
| [AC1] | Met / Partial / Missing | [file, test] |

### Business rules

| Rule | Status | Location |
|------|--------|----------|
| [RN01] | Met / Missing | [type.method] |

---

## Files reviewed

- [path] — [brief note]

---

## Positives

- [Specific good practices observed]

---

## Critical issues (blocking)

### [Issue title]

- **File:** `path:line`
- **Category:** Security | Bug | Breaking change
- **Problem:** [what is wrong]
- **Impact:** [why it blocks merge]
- **Suggested fix:** [concrete steps]

---

## Important issues (non-blocking)

### [Issue title]

- **File:** `path:line`
- **Problem:** [what to improve]
- **Suggestion:** [how]

---

## Nice-to-have

- [Optional improvements]

---

## Tests

- **Unit:** [pass/fail, scope]
- **Integration:** [pass/fail, scope]
- **Gaps:** [untested scenarios worth adding]

---

## Security

- [ ] No hardcoded secrets
- [ ] Input validation on external data
- [ ] No sensitive data in logs
- [ ] Parameterized data access (no SQL string concat)

Issues: [None | listed]

---

## Performance

- [ ] No obvious N+1 in touched code
- [ ] Async used for I/O-bound work
- [ ] No unbounded loops or allocations in hot paths

Issues: [None | listed]

---

## Refactoring opportunities (optional)

| Priority | Area | Benefit |
|----------|------|---------|
| Medium | [method/class] | [readability / testability] |

---

## Final recommendation

**Decision:** [Approved | Approved with reservations | Changes required]

**Required before merge:**

1. [Action or None]

**Recommended after merge:**

1. [Action or None]

**Next steps for author:**

- [ ]
```

---

## .NET review checklist (condensed)

**Structure**

- [ ] Clean Architecture layers respected
- [ ] Namespaces and folder layout consistent
- [ ] Single responsibility; focused methods

**C#**

- [ ] Explicit types; nullable reference types where enabled
- [ ] Async/await for I/O; `CancellationToken` propagated
- [ ] No unjustified `dynamic` or blocking `.Result` / `.Wait()`
- [ ] Resources disposed (`using`, `IAsyncDisposable`)

**Tests**

- [ ] xUnit + Moq + FluentAssertions
- [ ] Names: `Should_<Result>_When_<Condition>`
- [ ] Arrange / Act / Assert structure
- [ ] Edge cases and failure paths where behavior changed

**EF / data**

- [ ] No obvious N+1; `AsNoTracking` for read-only queries when appropriate
- [ ] Migrations safe (up/down, indexes, no unintended data loss)

---

## Angular / frontend checklist (when applicable)

- [ ] No unjustified `any`; typed inputs and API models
- [ ] HTTP errors handled; services return typed results
- [ ] Build: `npm run build` (or project script)
- [ ] Tests: `npm test` when present

---

## Code smell quick scan

| Smell | Look for |
|-------|----------|
| Long method | > ~30 lines in changed code |
| Large class | Multiple unrelated responsibilities |
| Duplication | Same logic in 2+ places |
| Feature envy | Method mostly uses another type’s data |
| Primitive obsession | Many primitives where a value object fits |

---

## Approval criteria

**Approved:** PRD/PLAN satisfied; no critical issues; build/tests pass or user accepts documented gaps.

**Approved with reservations:** Minor issues or PLAN cosmetic drift; no security or correctness blockers.

**Changes required:** Security vulnerability; broken behavior; missing PRD scope; build/test failure; critical architecture violation.
