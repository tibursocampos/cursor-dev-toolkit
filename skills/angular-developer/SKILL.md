---
name: angular-developer
description: >
  Implement or fix small-to-medium Angular features without full SDD. Uses Angular, components, services,
  RxJS, dependency injection, Jasmine/Karma, and Git-only developer flow. Use for isolated Angular work.
  For larger cross-cutting features, route to sdd-spec -> sdd-plan -> sdd-develop.
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
[ ] User confirmed current action (sim)
-> If any unchecked: STOP
```

---

## Trigger

Use when user asks for `use skill angular-developer`, `angular fix`, or a small isolated Angular implementation.

## Outcome

Working Angular code and tests in the target workspace, validated with tests/build, with optional handoff to `use skill commit`.

## When to escalate to SDD

Recommend `sdd-spec` -> `sdd-plan` -> `sdd-develop` if two or more apply: 3+ layers touched, new modules/services across app, cross-repo impact, 10+ files, or existing approved PLAN.

## DESIGN-BRIEF acceptance

If `docs/DESIGN-BRIEF.md` or `docs/design/DESIGN-BRIEF.md` exists, treat it as the acceptance source. Map sections to Angular components/templates; do **not** reinterpret visual decisions. Implement **one session scope** from section 10 only.

If the task is net-new UI without a brief, recommend `use skill impeccable shape` in a **new session** before implementing.

## Lazy-load references

| When | Path |
|------|------|
| Design brief | `docs/DESIGN-BRIEF.md` or `docs/design/DESIGN-BRIEF.md` |
| Branch / commit | `~/.cursor/rules/branch-validation.mdc`, `~/.cursor/skills/_shared/developer-common/step-3-branching.md` |
| Angular guidelines | `~/.cursor/skills/_shared/angular-guidelines/` |
| Frontend practices | `~/.cursor/skills/_shared/frontend-guidelines/frontend-practices.md` |
| Markup / styles | `~/.cursor/skills/_shared/html-css-guidelines/` |
| Principles | `~/.cursor/skills/_shared/code-guidelines/principles/` |
| Context | `~/.cursor/rules/context-management.mdc` |
| Caveman (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` |

Do not preload unrelated guideline trees.

## Process

### 0. Workspace

Confirm Angular project (`angular.json` or `@angular/core` in `package.json`). Summarize acceptance.

### 1. Guidelines

Load only required Angular/frontend guidelines for this task.

### 2. Branch

Use `feature/<slug>` or `feat/<id>`. Never commit on default integration branches.

### 3. Micro-plan

Define 3-7 concrete tasks; checkpoint context at >= 40%.

### 4. Implement

Components, services, RxJS patterns. Match existing module structure.

### 5. Tests

Jasmine/Karma (or project test runner) for changed behavior.

### 6. Validate

```bash
ng test
ng build
```

(or project-equivalent scripts)

### 7. Handoff

Offer `use skill commit`. Do not commit automatically.

## Must not

- Auto-commit or auto-PR
- Leave AI traces in code or identifiers

## Handoff

| Situation | Next |
|-----------|------|
| Commit | `use skill commit` |
| Review | `use skill code-review` |
| Scope grew | `sdd-spec` -> `sdd-plan` -> `sdd-develop` |
| Missing design brief | `use skill impeccable shape` (new session) |
