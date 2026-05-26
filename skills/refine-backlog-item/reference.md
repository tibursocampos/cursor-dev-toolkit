# refine-backlog-item — reference

Scorecard, guardrails, and boundaries for `skills/refine-backlog-item/SKILL.md`. Keep `SKILL.md` under 150 lines.

---

## Boundary: refine-backlog-item vs spec

| Aspect | `refine-backlog-item` | `spec` |
|--------|----------------------|--------|
| Purpose | Fast intake — clarify a single backlog item | Full PRD for medium/high complexity features |
| Output | Structured markdown + scorecard in chat | PRD with manifest, storage rules, traceability |
| Persistence | Optional `docs/backlog/<slug>.md` — **not** a substitute for SDD PRD | `PRD/` or `docs/PRD/` or `~/.cursor/sdd/<repo-id>/PRD/` (see `STORAGE.md`, `PIPELINE.md`) |
| Acceptance | BDD in item template; scorecard rubric | PRD acceptance criteria + SDD PLAN linkage |
| When to escalate | User confirms feature spans multiple areas, migrations, or unclear scope | Invoke `use skill spec` — do not expand refine into a PRD inline |

`spec` does **not** replace refine for a one-line idea — refine first, then spec if needed.

Handoff wording:

```
This item is large enough for SDD. Next: use skill spec — then use skill plan.
```

Before suggesting `spec`, optionally Glob existing PRDs in **both** workspace (`PRD/*.md`, `docs/PRD/*.md`) and global (`~/.cursor/sdd/<repo-id>/PRD/*.md`) per `STORAGE.md` — mention if a related PRD already exists so the user can extend it instead of duplicating scope.

`spec` owns storage choice (repository vs global), manifest, `.gitignore`, and confirm-before-write (`PIPELINE.md`); refine does **not** write PRD/PLAN files. `docs/backlog/` items must be promoted via `use skill spec`, not treated as PRD.

---

## Scorecard rubric

Score immediately after generating the markdown. Maximum **100** points.

### Universal criteria (all types)

| Criterion | Max | Scoring guide |
|-----------|-----|----------------|
| Objective | 15 | 15: affirmative, ≤3 sentences, correct perspective, specific / 8: correct but long or generic / 3: vague or wrong perspective / 0: missing |
| Acceptance criteria (BDD) | 25 | 25: all Given/When/Then, covers happy path + error + edge / 15: BDD present but incomplete / 8: no BDD or intent language / 0: missing |
| Implementation steps | 20 | 20: baby steps, infinitive verbs, layer order, explicit deps / 12: steps ok but weak granularity or deps / 5: generic steps / 0: missing |
| No vague language | 10 | 10: none / 5: 1–2 vague phrases / 0: multiple |

### Type-specific criteria (30 points total)

**Technical Story:**

| Criterion | Max |
|-----------|-----|
| Technical context (problem → solution → scope) | 10 |
| Repositories / areas listed | 5 |
| Technical specificity (types, endpoints, events when relevant) | 10 |
| Dependencies declared or N/A justified | 5 |

**User Story:**

| Criterion | Max |
|-----------|-----|
| Context + current vs expected flow | 10 |
| Repositories / areas listed | 5 |
| Business AC vs technical AC separated | 10 |
| Dependencies declared or N/A justified | 5 |

**Bug:**

| Criterion | Max |
|-----------|-----|
| Repro steps + evidence | 10 |
| Frequency and impact | 5 |
| Suggested fix steps with files and deps | 10 |
| Non-regression BDD scenario | 5 |

### Scorecard output format

```markdown
---

## 📊 Quality scorecard

| Criterion | Score | Max | Note |
|-----------|-------|-----|------|
| Objective | [x] | 15 | [specific note] |
| Acceptance criteria (BDD) | [x] | 25 | [specific note] |
| Implementation steps | [x] | 20 | [specific note] |
| No vague language | [x] | 10 | [specific note] |
| [type-specific 1] | [x] | [max] | [specific note] |
| [type-specific 2] | [x] | [max] | [specific note] |
| [type-specific 3] | [x] | [max] | [specific note] |
| [type-specific 4] | [x] | [max] | [specific note] |

### 🏆 Total: [sum] / 100

### ✅ Strengths
- [specific]

### ⚠️ Improvements
- **[Criterion]**: [what is missing and how to fix]

---
```

Rules: notes must be specific (not "OK"); improvements name exact gaps; incomplete user input reflected honestly.

---

## Guardrails (before marking output final)

**Universal:**

- [ ] No empty or placeholder sections
- [ ] No vague phrases: "works correctly", "as expected", "properly"
- [ ] BDD uses **Given / When / Then / And**
- [ ] No unit-test scenarios in acceptance criteria
- [ ] No "verify environment variable X" as acceptance criteria
- [ ] Section icons/headings match the type template when saving

**Technical Story / User Story:**

- [ ] Steps ordered by layer when applicable
- [ ] Dependencies section omitted when none (not "N/A" filler)

**User Story:**

- [ ] Business AC without implementation jargon
- [ ] Technical AC as checkboxes, not BDD

**Bug:**

- [ ] Reproduction steps are actionable
- [ ] Expected result describes positive behavior

If guardrails fail, ask for missing detail — do not publish incomplete docs.

---

## Optional save: `docs/backlog/<slug>.md`

Prefix file with metadata:

```markdown
# Backlog: [title]

| Field | Value |
|-------|--------|
| **Type** | Bug \| User Story \| Technical Story |
| **Doc language** | pt-BR \| English |
| **Refined** | YYYY-MM-DD |
| **Repository** | [folder or remote name] |

[generated body]
```

Do not create `docs/backlog/` in **cursor-dev-toolkit** during toolkit porting — only in consumer repos at runtime.

---

## Relationship to breakdown-tasks

| Skill | Use |
|-------|-----|
| `refine-backlog-item` | Produces steps under `### 🧩 Steps` (or Bug suggested fix) |
| `breakdown-tasks` | Groups those steps into an implementation task checklist file |

After refine, offer:

```
use skill breakdown-tasks
```

Pass the saved path or ask the user to confirm the chat content is the source.
