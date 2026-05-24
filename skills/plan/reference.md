# PLAN template (plan skill)

Use this template when writing `PLAN/PLAN_NNN_feature_slug.md`. All section titles and body text must be **English**. Replace bracketed placeholders.

## Filename and numbering

| Part | Rule |
|------|------|
| Folder | `PLAN/` at repository root |
| Sequence | Same `NNN` (3 digits) as the source PRD |
| Slug | Short kebab-case English summary |
| Example | `PLAN/002_user_profile_export.md` |
| PRD link | `PRD/002_user_profile_export.md` or `docs/PRD/...` |

---

## Document template

Copy from the heading below through **Final checklist**, then remove instructional comments in brackets.

```markdown
# PLAN: [Feature name]

| Field | Value |
|-------|--------|
| **PRD** | PRD/NNN_feature_slug.md |
| **Repository** | [name from PRD / git root] |
| **Stack** | [.NET / Angular / other] |
| **Complexity** | Low / Medium / High |
| **Total steps** | N (MVP) + M optional |
| **Progress** | 0/N |

```
[⚪⚪⚪⚪⚪⚪⚪⚪] 0% (0/N)
```

## Objectives

- [ ] O1: [Measurable outcome tied to PRD]
- [ ] O2: [Measurable outcome]
- [ ] O3: [Optional]

## Target tree (deliverables)

[List main files or modules to create or change — paths only, no code.]

```
[repo-root]/
├── [paths from exploration]
└── [tests]
```

## Validation strategy

- [ ] [How this feature will be verified — unit, integration, manual]
- [ ] .NET: xUnit, Moq, FluentAssertions; `Should_<Result>_When_<Condition>`
- [ ] Build passes locally / CI

---

## Implementation steps

### ⏳ STEP 1: [Short title]

**Status:** Pending | **Completed:** - | **Deps:** none | **Token budget:** ~[k] | **Time:** [min]

**Deliverables:**

- [ ] [Concrete artifact 1]
- [ ] [Concrete artifact 2]

**Files:**

- `path/to/file.cs` (new or modify)

**Tasks:**

1. [Action]
2. [Action]

**Tests:**

- [ ] `Should_<Result>_When_<Condition>`
- [ ] [Additional scenario]

**Acceptance:**

- [ ] [Criterion from PRD AC]
- [ ] Build and targeted tests pass

**Notes:** [Risks, dense-step warning if 4+ files]

---

### ⏳ STEP 2: [Short title]

**Status:** Pending | **Completed:** - | **Deps:** 1 | **Token budget:** ~[k] | **Time:** [min]

[Repeat STEP block structure for each baby step.]

---

## Execution order

**Critical path:** 1 → 2 → … → N

**Next step:** STEP 1 — [title]

---

## Component map

| Layer / area | Paths |
|--------------|-------|
| Domain | [paths] |
| Application | [paths] |
| Infrastructure | [paths] |
| API / UI | [paths] |
| Tests | [paths] |

## Test strategy

### Unit

- [ ] [Scenario]

### Integration

- [ ] [Scenario]

### Manual (if needed)

- [ ] [Scenario]

## Technical decisions

| Topic | Decision | Rationale |
|-------|----------|-----------|
| [e.g. property name] | [choice] | [why] |

## Risks and mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk 1] | Low/Med/High | [Action] |

## References

- PRD: `PRD/NNN_feature_slug.md`
- Project docs: `docs/...`
- Guidelines (lazy-load after sync; do not paste bodies):
  - `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md`
  - `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md`

## PLAN update protocol (for implement skill)

After each completed step, the **implement** skill updates this file:

1. Step status → **Completed** with date
2. Progress bar and `Progress` field
3. Objective checkboxes when satisfied
4. **Next step** line points to the following STEP

Do not edit PLAN progress manually during implementation unless recovering from a failed session.

## Final checklist

- [ ] All PRD acceptance criteria mapped to steps
- [ ] Each step fits one implement session
- [ ] Dependencies explicit; no circular deps
- [ ] Test scenarios cover AC and edge cases
- [ ] No implementation code embedded in PLAN
- [ ] Handoff: `use skill implement — PLAN/PLAN_NNN_feature_slug.md — Step 1`
```

---

## Status legend

| Marker | Meaning |
|--------|---------|
| ⏳ STEP N | Pending |
| 🔄 STEP N | In progress (implement session active) |
| ✅ STEP N | Completed |
| ❌ STEP N | Blocked |

Use **Pending** / **Completed** / **Blocked** in the `**Status:**` line; emoji in the step heading is optional for scanability.

---

## Baby-step sizing checklist

Before finalizing the PLAN:

- [ ] No step targets 4+ new files without a split
- [ ] Migration and EF mapping are separate when both apply
- [ ] Handler, consumer, and tests are not all in one step unless trivial
- [ ] Dense steps include a context warning for implement
- [ ] Optional docs-update step only if contracts or user-visible behavior change

---

## Quality checklist (before handoff)

- [ ] PRD path and sequence match PLAN filename
- [ ] Every PRD acceptance criterion appears in at least one step
- [ ] Steps are English; no code blocks with full implementations
- [ ] Output path is `PLAN/PLAN_NNN_*.md` (not `PLANO_*` or repo root)
- [ ] Handoff uses `use skill implement`, not deprecated aliases
- [ ] Progress block shows `0/N` initially
