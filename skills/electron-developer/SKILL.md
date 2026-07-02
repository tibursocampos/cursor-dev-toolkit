---
name: electron-developer
description: >
  Implement or fix small-to-medium Electron desktop features without full SDD. Covers main process,
  preload scripts, renderer (React/Vue/vanilla), IPC, security, and packaging. Orchestrates renderer
  stack guidelines without delegating skill identity. For large cross-cutting features, route to SDD.
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

Use when user asks for `use skill electron-developer`, `electron fix`, or a small isolated Electron implementation.

## Outcome

Working main/preload/renderer changes, validated with build and documented smoke (app launch), with optional handoff to `use skill commit`.

## Renderer stack (orchestration)

Detect renderer framework from `package.json`:

| Dependency | Lazy-load guidelines |
|------------|---------------------|
| `react` | `react-guidelines/` |
| `vue` | `vue-guidelines/` |
| Neither | `javascript-guidelines/`, `html-css-guidelines/` |

**Stay in `electron-developer` identity** - load stack guidelines for UI patterns only; do not switch to `react-developer` / `vue-developer`.

## When to escalate to SDD

Recommend `sdd-spec` -> `sdd-plan` -> `sdd-develop` if two or more apply: main+renderer+packaging overhaul, auto-update pipeline, cross-repo impact, 10+ files, or existing approved PLAN.

## DESIGN-BRIEF acceptance

If `docs/DESIGN-BRIEF.md` or `docs/design/DESIGN-BRIEF.md` exists, treat it as the acceptance source. Map sections to renderer UI; do **not** reinterpret visual decisions. Implement **one session scope** from section 10 only.

If the task is net-new UI without a brief, recommend `use skill impeccable shape` in a **new session** before implementing.

## Lazy-load references

| When | Path |
|------|------|
| Design brief | `docs/DESIGN-BRIEF.md` or `docs/design/DESIGN-BRIEF.md` |
| Branch / commit | `~/.cursor/rules/branch-validation.mdc`, `~/.cursor/skills/_shared/developer-common/step-3-branching.md` |
| Electron guidelines | `~/.cursor/skills/_shared/electron-guidelines/` |
| Renderer stack | `react-guidelines/` or `vue-guidelines/` or `javascript-guidelines/` |
| Frontend core | `~/.cursor/skills/_shared/frontend-guidelines/frontend-practices.md` |
| Markup / styles | `~/.cursor/skills/_shared/html-css-guidelines/` |
| Principles | `~/.cursor/skills/_shared/code-guidelines/principles/` |
| Context | `~/.cursor/rules/context-management.mdc` |
| Caveman (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` |

Do not preload unrelated guideline trees.

## Process

### 0. Workspace

Confirm Electron project (`electron`, `electron-builder`, or `electron-vite` in `package.json`). Identify main/preload/renderer entry points.

### 1. Guidelines

Load Electron + renderer guidelines for this task. Review security defaults before IPC changes.

### 2. Branch

Use `feature/<slug>` or `feat/<id>`. Never commit on `main`/`master`/`develop`.

### 3. Micro-plan

Define 3-7 concrete tasks; checkpoint context at >= 40%.

### 4. Implement

Main/preload/renderer separation, typed IPC, contextIsolation. Match existing electron-vite or electron-builder layout.

### 5. Tests

Unit tests for pure modules; manual smoke: app launches, changed flow works.

### 6. Validate

```bash
npm run build
```

Document smoke steps in chat (launch app, exercise changed feature).

### 7. Handoff

Offer `use skill commit`. Do not commit automatically.

## Must not

- Enable `nodeIntegration: true` in renderer without explicit user approval
- Expose raw `ipcRenderer` on `window` without contextBridge
- Auto-commit or auto-PR
- Leave AI traces in code or identifiers

## Handoff

| Situation | Next |
|-----------|------|
| Commit | `use skill commit` |
| Review | `use skill code-review` |
| Scope grew | `sdd-spec` -> `sdd-plan` -> `sdd-develop` |
| Missing design brief | `use skill impeccable shape` (new session) |
