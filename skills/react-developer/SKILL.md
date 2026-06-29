---
name: react-developer
description: >
  Implement or fix small-to-medium React features without full SDD. Uses React, functional components, hooks,
  TSX/JSX, Jest/React Testing Library, and Git-only developer flow. Use for isolated React work.
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

Use when user asks for `use skill react-developer`, `react fix`, or a small isolated React implementation.

## Outcome

Working React components and tests in the target workspace, validated with tests/build, with optional handoff to `use skill commit`.

## When to escalate to SDD

Recommend `sdd-spec` -> `sdd-plan` -> `sdd-develop` if two or more apply: 3+ layers touched, new API contracts, cross-repo impact, 10+ files, or existing approved PLAN.

## Lazy-load references

| When | Path |
|------|------|
| Branch / commit | `~/.cursor/rules/branch-validation.mdc`, `~/.cursor/skills/_shared/developer-common/step-3-branching.md` |
| React guidelines | `~/.cursor/skills/_shared/react-guidelines/` |
| Frontend practices | `~/.cursor/skills/_shared/frontend-guidelines/frontend-practices.md` |
| Principles | `~/.cursor/skills/_shared/code-guidelines/principles/` |
| Context | `~/.cursor/rules/context-management.mdc` |
| Caveman (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` |

Do not preload unrelated guideline trees.

## Process

### 0. Workspace

Confirm React project (`package.json` with React). Read `README.md`, summarize acceptance.

### 1. Guidelines

Load only required React/frontend guidelines for this task.

### 2. Branch

Use `feature/<slug>` or `feat/<id>`. Never commit on `main`/`master`/`develop`.

### 3. Micro-plan

Define 3-7 concrete tasks; checkpoint context at >= 40%.

### 4. Implement

Functional components, hooks, clean React architecture. Match existing patterns.

### 5. Tests

Jest / React Testing Library for changed behavior.

### 6. Validate

```bash
npm test
npm run build
```

(or project-equivalent scripts)

### 7. Handoff

Offer `use skill commit`. Do not commit automatically.

## Must not

- Auto-commit or auto-PR
- Leave AI traces in code or identifiers
- Use obsolete corporate pipeline docs

## Handoff

| Situation | Next |
|-----------|------|
| Commit | `use skill commit` |
| Review | `use skill code-review` |
| Scope grew | `sdd-spec` -> `sdd-plan` -> `sdd-develop` |
