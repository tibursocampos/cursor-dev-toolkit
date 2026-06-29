---
name: developer
description: >
  Generic development skill. Acts as a smart router for heavy frameworks (delegating to specialized stack skills) OR
  acts directly as a Senior Fullstack/DevOps engineer for ad-hoc scripts, HTML, and automation tasks.
  Use when the user says "use skill developer" or requests generic coding without specifying a stack.
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

Use when user asks for `use skill developer` or requests generic coding/refactoring tasks without specifying a stack.

## Outcome

Correct stack skill loaded and executed, or ad-hoc implementation in fallback mode with optional handoff to `use skill commit`.

## Lazy-load (only when needed)

| When | Path (after `scripts/sync-cursor.ps1`) |
|------|----------------------------------------|
| Git / language policy | `~/.cursor/AGENTS.md`, `~/.cursor/rules/branch-validation.mdc` |
| Developer flow | `~/.cursor/skills/_shared/developer-common/GUIDE.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |
| Caveman Mode (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` |

Do **not** load `dev_persona` or Antigravity KI artifacts.

## Routing Logic

1. **Inspect the workspace**: Look for project files to identify the stack.
   - `.csproj` / `.sln` -> C# / .NET
   - `package.json` (with React) -> React
   - `package.json` (with Angular) -> Angular
   - `package.json` (Node.js/Generic) -> JavaScript/Node
   - `.py`, `requirements.txt`, `pyproject.toml` -> Python

2. **Invoke the specialized skill (if match found)**:
   - Silently read the `SKILL.md` of the matched stack under `~/.cursor/skills/`:
     - `dotnet-developer`, `react-developer`, `angular-developer`, `javascript-developer`, or `python-developer`
   - Assume the identity and instructions of that skill immediately.
   - Do **not** ask the user for confirmation to switch skills.

3. **Fallback mode (if no match found)**:
   - If no major framework structure is detected (e.g., isolated `.html`, `.sh`, `.bat`, `.ps1` files), **do not delegate**.
   - Assume the task directly using standard, secure engineering practices as a Senior Developer.
   - Proceed to the Execution Process below.

## Execution Process (fallback mode only)

### 0. Workspace

Confirm target repo, read `README.md` (if exists), and summarize requested acceptance.

### 1. Micro-plan

Define 2-5 concrete tasks. Checkpoint context usage after each major change per `context-management.mdc`.

### 2. Implement

Write clean, maintainable code following universal best practices for the target language (e.g., HTML, Bash, Python script).

### 3. Tests / Validation

Run local scripts or linting tools to ensure the code executes without syntax errors.

### 4. Handoff

Offer `use skill commit`. Do not commit automatically.

## Must not

- Auto-commit or auto-PR
- Leave AI traces in code comments or identifiers (see `ai-stealth.mdc`)
- Delegate when a clear stack match exists

## Handoff

| Situation | Next |
|-----------|------|
| Commit | `use skill commit` |
| .NET work (explicit) | `use skill dotnet-developer` |
| Large scope | `use skill sdd-spec` -> `sdd-plan` -> `sdd-develop` |
