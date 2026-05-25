# plan-repo-docs — reference

Templates and checklists for `skills/plan-repo-docs/SKILL.md`. Keep `SKILL.md` under 150 lines.

---

## Stack detection (step 0)

Use Glob from repo root. Combine signals; report confidence.

| Signal | Glob / read |
|--------|-------------|
| .NET | `**/*.sln`, `**/*.csproj`, `**/Program.cs` |
| Node / frontend | `package.json`, `pnpm-lock.yaml`, `angular.json`, `vite.config.*` |
| Python | `pyproject.toml`, `requirements.txt`, `setup.py` |
| Go | `go.mod` |
| Java | `pom.xml`, `build.gradle*` |
| Rust | `Cargo.toml` |
| Docker / compose | `Dockerfile`, `docker-compose*.yml` |
| CI | `.github/workflows/*.yml`, `azure-pipelines.yml` (describe generically if present) |

Read one representative project file per stack found. Do not invent versions — read from manifests when needed.

**Overview content hints (stack-agnostic):**

- Repository purpose (from README / user)
- Top-level folder map
- How to build and test (commands from repo docs)
- Major deployable units (services, apps, libraries)
- Data stores and messaging (only if evidenced in code/config)

---

## Output paths (consumer repo only)

| Artifact | Path |
|----------|------|
| High-level summary | `docs/overview.md` |
| Documentation plan | `docs/documentation-plan/plan.md` |
| Domain docs (later) | `docs/domains/<slug>.md` or path declared in plan steps |

Paths are English. Prose language = user choice (pt-BR or English).

---

## Plan template (`docs/documentation-plan/plan.md`)

Copy and adapt in the **target repository**. Section titles may be pt-BR or English to match `doc_language`.

```markdown
# Documentation plan: [Repository name]

| Field | Value |
|-------|--------|
| **Repository** | [git remote or folder name] |
| **Doc language** | pt-BR \| English |
| **Stack detected** | [.NET, Angular, … from step 0] |
| **Overview** | docs/overview.md |
| **Progress** | 0/N |

```
[⚪⚪⚪⚪⚪] 0% (0/N)
```

## Goals

- [ ] G1: RAG-ready markdown per domain
- [ ] G2: Integrations and boundaries documented
- [ ] G3: Architecture patterns evidenced from code

## Target doc tree (consumer repo)

```
docs/
├── overview.md
├── documentation-plan/
│   └── plan.md
└── domains/
    └── <domain-slug>.md
```

---

## Implementation steps

### ⏳ STEP 1: [Domain or area title]

**Status:** Pending | **Completed:** - | **Deps:** none | **Est.:** 30–45 min

**Deliverables:**
- [ ] `docs/domains/<slug>.md` — purpose, main types, flows, extension points

**Tasks:**
1. Glob/Grep bounded context folders
2. Read entry points (API, consumers, UI modules)
3. Write markdown in **doc language**; English identifiers for paths/types

**Acceptance:**
- [ ] New developer can locate main code paths from the doc alone

---

### ⏳ STEP 2: [Integrations]

**Status:** Pending | **Completed:** - | **Deps:** 1 | **Est.:** 30 min

**Deliverables:**
- [ ] Section in `docs/domains/<slug>.md` or `docs/integrations.md`

**Tasks:**
1. Grep HTTP clients, message consumers, SDK config
2. Document external systems, contracts, failure modes (no secret values)

---

### ⏳ STEP 3: [Architecture patterns]

**Status:** Pending | **Completed:** - | **Deps:** 1 | **Est.:** 25 min

**Deliverables:**
- [ ] `docs/architecture/patterns.md` or section in overview

**Tasks:**
1. Evidence layers (Clean Architecture, CQRS, etc.) from structure — do not assert patterns not present
2. Link to representative files (paths only)

---

## Execution order

**Critical path:** 1 → 2 → 3 → …

**Next step:** STEP 1 — [title]

## Update protocol (document-repo skill)

After each completed step, `document-repo` updates this file: status, progress bar, **Next step** line, and checked deliverables.
```

Add steps until domains and integrations from exploration are covered. Prefer 5–12 baby steps for medium repos.

---

## Planning checklist (before Write)

- [ ] Language asked and recorded
- [ ] Overview reflects detected stack (not a template from another company)
- [ ] Each step has deliverable path, tasks, acceptance
- [ ] No ADO/work-item URLs required
- [ ] Steps fit one `document-repo` session when possible

---

## Context management

Per `~/.cursor/rules/context-management.mdc`:

- After overview + plan draft: checkpoint
- When planning many domains in one session: save `plan.md` at ≥ 40% and hand off continuation

Pause message includes: `docs/documentation-plan/plan.md` path, steps completed, next step id.

---

## Relationship to SDD

| Skill | Use |
|-------|-----|
| `plan` / `implement` | Feature delivery PRD/PLAN — `PRD/`, `PLAN/`, or `~/.cursor/sdd/<repo-id>/` per `STORAGE.md` |
| `plan-repo-docs` | Cross-cutting documentation strategy — output `docs/documentation-plan/plan.md` only |
| `document-repo` | Executes one step of `docs/documentation-plan/plan.md` |

Do **not** read or write SDD `PLAN/PLAN_*.md` when executing `plan-repo-docs` / `document-repo`. Do **not** read `docs/documentation-plan/plan.md` when executing SDD `plan` / `implement`.
