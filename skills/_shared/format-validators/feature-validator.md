# PRD Format Validator

Validates PRD markdown against the **spec** skill template.

**Template reference:** `skills/spec/reference.md`  
**Output paths:** `PRD/NNN_feature_slug.md` or `docs/PRD/NNN_feature_slug.md`

## Validation levels

### Level 1: Structure (required)

**Required sections (in order, after title/metadata table):**

- `# PRD:` title
- Metadata table (`Sequence`, `Status`, `Priority`, `Complexity`, `Repository`, `Stack`)
- `## 1. Overview` (with `### 1.1 Context`, `### 1.2 Objective`)
- `## 2. Acceptance criteria` (at least one `### ACn` block with Given/When/Then)
- `## 3. Technical scope (high level)`
- `## 4. Technical specifications`
- `## 5. Out of scope`
- `## 6. Risks and dependencies`
- `## 7. Test strategy (high level)`
- `## 8. Definition of done`
- `## 9. Handoff to plan`
- `## Change history`

### Level 2: Content (recommended)

| Field / section | Rule | Severity |
|-----------------|------|----------|
| Metadata `Status` | Not `[TBD]` or empty placeholder | error |
| Metadata `Priority` | `High`, `Medium`, or `Low` | error |
| Metadata `Complexity` | `Low`, `Medium`, or `High` | error |
| `### 1.2 Objective` | Non-empty, not bracket placeholder | error |
| `## 2. Acceptance criteria` | At least 2 AC blocks | warning |
| `## 8. Definition of done` | At least 3 checkboxes, no `[Criterion X]` placeholders | warning |

### Level 3: Quality (optional)

| Section | Rule | Severity |
|---------|------|----------|
| `### 1.1 Context` | Minimum ~80 characters | info |
| Acceptance criteria | Given/When/Then present in each AC | info |
| `## 9. Handoff to plan` | Contains `use skill plan` with PRD path | info |

## Usage in spec skill

**Integration point:** After generating PRD content, before writing the file.

**Flow:**

1. Validate at `level: content`.
2. On errors: log section + expected + actual + suggestion; offer regenerate or save with warning.
3. Warnings: show improvements; do not block save.
4. `canAutoFix = false` — PRD issues usually need human input.

## Output example

```text
Validating PRD format...

PRD does not fully match template:
  ## 2. Acceptance criteria: only one AC block found
     Expected: at least 2 AC blocks | Actual: 1

Suggestions:
  - ### 1.1 Context: expand problem statement and current state

PRD saved with warnings — review manually.
```

---

**Version:** 1.0.0 (cursor-dev-toolkit)
