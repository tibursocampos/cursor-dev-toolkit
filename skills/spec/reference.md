# PRD template (spec skill)

Use this template when writing `PRD/NNN_feature_slug.md` or `docs/PRD/NNN_feature_slug.md`. All section titles and body text must be **English**. Replace bracketed placeholders.

## Filename and numbering

| Part | Rule |
|------|------|
| Folder | `PRD/` preferred; `docs/PRD/` if the repo uses that layout |
| Sequence | Next `NNN` (3 digits) after listing existing `PRD/*.md` and `docs/PRD/*.md` |
| Slug | Short kebab-case English summary |
| Example | `PRD/002_user_profile_export.md` |

---

## Document template

Copy from the heading below through **Change history**, then remove instructional comments in brackets.

```markdown
# PRD: [Feature name]

| Field | Value |
|-------|--------|
| **Sequence** | NNN |
| **Tracking** | [GitHub issue / slug / TBD] |
| **Version** | 1 |
| **Date** | YYYY-MM-DD |
| **Status** | Ready for planning |
| **Priority** | High / Medium / Low |
| **Complexity** | Low / Medium / High |
| **Repository** | [name from git root] |
| **Stack** | [.NET / Angular / other] |

## 1. Overview

### 1.1 Context

[Why is this needed? Current situation and problem.]

### 1.2 Objective

[Desired outcome after implementation.]

## 2. Acceptance criteria

Use BDD: **Given** / **When** / **Then** / **And**.

### AC1 — [Descriptive name]

**Given** [initial context]
**When** [action]
**Then** [expected result]
**And** [optional extra condition]

### AC2 — [Descriptive name]

**Given** [initial context]
**When** [action]
**Then** [expected result]

## 3. Technical scope (high level)

### 3.1 Components to modify

[List modules, services, or areas — no code.]

### 3.2 New components

[List new modules, endpoints, or artifacts — no code.]

### 3.3 Reuse without change

[Existing pieces reused as-is.]

### 3.4 Data flow

[Textual flow or diagram description between components.]

## 4. Technical specifications

Describe responsibilities and contracts **without** code samples.

### 4.1 Domain / entities

[Fields, types, constraints at business level.]

### 4.2 DTOs / commands / queries

[Inputs and outputs — names optional, shapes required.]

### 4.3 Handlers / services

[Business responsibilities.]

### 4.4 Data access

[Operations needed — read/write patterns.]

### 4.5 Events / messaging

[Published or consumed payloads, if any.]

### 4.6 Validations

[Rules and error expectations.]

## 5. Business rules

- **BR01**: [Rule]
- **BR02**: [Rule]

## 6. Functional requirements

- **FR01**: [Requirement]
- **FR02**: [Requirement]

## 7. Non-functional requirements

- **NFR01**: [Performance, security, observability, etc.]
- **NFR02**: [Requirement]

## 8. Database migrations (if applicable)

**Migration required?** Yes / No

If yes: tables/columns affected, impact on existing data, reversibility.

## 9. Integrations (if applicable)

### 9.1 External systems

[List APIs, queues, third parties.]

### 9.2 Contract changes

[Payload or API changes; breaking change Yes/No with justification.]

## 10. Error handling

### EH01 — [Scenario name]

- **Situation**: [When it occurs]
- **Handling**: [Expected behavior]
- **User/log message**: [Message intent]

## 11. Use cases

### UC01 — [Primary use case]

**Actor:** [User / system / service]

**Preconditions:**

- [Condition]

**Main flow:**

1. [Step]
2. [Step]
3. [Expected result]

**Alternate flows:**

- **AF01**: [Exception or branch]

## 12. Test scenarios

Mirror acceptance criteria; add edge and failure paths.

### TS1 — [Happy path]

**Given** … **When** … **Then** …

### TS2 — [Validation / edge]

**Given** … **When** … **Then** …

## 13. Definition of done

- [ ] Implementation matches this PRD
- [ ] Unit/integration tests for new behavior
- [ ] For .NET: tests use xUnit, Moq, FluentAssertions; names `Should_<Result>_When_<Condition>`
- [ ] Migrations applied and verified (if applicable)
- [ ] Code review completed
- [ ] Build passes in CI/local

**Angular (if applicable):** build, typecheck, and frontend tests pass.

## 14. Next steps

This PRD is ready for the **plan** skill:

```
use skill plan — PRD/NNN_feature_slug.md
```

## 15. References

- [Project docs under `docs/`]
- [Related PRDs]
- [External links]

Guidelines (lazy-load paths after sync, do not paste bodies here):

- `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md`
- `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md`

## 16. Notes

**Risks:**

- [Risk]

**Dependencies:**

- [Dependency]

## 17. Change history

| Date | Version | Author | Description |
|------|---------|--------|-------------|
| YYYY-MM-DD | 1 | [Name] | Initial version |
```

---

## Quality checklist (before handoff)

- [ ] No implementation code in the PRD
- [ ] Every acceptance criterion is testable
- [ ] Complexity and risks documented
- [ ] Output path is `PRD/` or `docs/PRD/` (not repo root)
- [ ] Status is **Ready for planning**
- [ ] Next step points to `use skill plan`
