---
name: speckit-develop
description: >
  Implement exactly one pending tasks.md item per session; code in English.
  Use when the user says "use skill speckit-develop", "implement speckit task", or "/speckit-develop".
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
[ ] PIPELINE.md read (SDD/speckit skills only)
[ ] User confirmed current action (sim)
-> If any unchecked: STOP
```

---

## Trigger

Invoke when the user asks for: `use skill speckit-develop`, `executar tarefa speckit`, `desenvolver spec kit`, or `/speckit-develop`.

## Outcome

Production code and/or tests written (in **English**) for one pending task from `tasks.md`. The `tasks.md` file updated with the task marked as complete (`- [x]`).

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Storage schema v2 and manifest | `_shared/sdd-artifacts/STORAGE.md` section Global Manifest and Dynamic Storage Resolution |
| Project architecture rules | `.specify/memory/constitution.md` (at resolved destination) |
| .NET / C# rules | `_shared/dotnet-guidelines/clean-architecture.md`, `_shared/dotnet-guidelines/csharp-patterns.md` |
| General code guidelines | `_shared/code-guidelines/` (based on detected stack) |
| Caveman Mode (if active) | `_shared/caveman/CAVEMAN.md` - Full mode |

## Process

### -1. Validate speckit initialization

Run `scripts/validation/validate-speckit-init.ps1` before any implementation workflow action.
- If validation fails: **STOP** and handoff to `use skill speckit-init`.
- If validation passes: continue.

### 0. Load context

Load `STORAGE.md` and run the dynamic storage resolution algorithm using schema v2 with parameter `$Workflow = speckit`. Resolve active destination. `Read` `.specify/memory/constitution.md` and apply constraints. Load stack-relevant guidelines.

Check `~/.cursor/sdd/preferences.json`:
- If file missing -> create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` -> load `_shared/caveman/CAVEMAN.md` (Full mode rules) and display:
  > Modo Caveman ativo (respostas compactas). Digite `caveman off` a qualquer momento para desativar.
- Honor `caveman on` / `caveman off` commands from the user at any point during the session.

### 1. Resolve tasks.md

The user should provide the `tasks.md` path (handoff from `speckit-plan`) or it will be resolved:

```
Glob: {destination}/.specify/specs/*/tasks.md
```

| Situation | Action |
|---|---|
| Path provided in handoff | `Read` directly |
| Multiple tasks.md found | List them and ask which one (pt-BR) |
| None found | Redirect to `speckit-plan` |

### 2. Identify next task

Read `tasks.md`. Find the **first** item marked `- [ ]`.

- If no pending task:
  - Inform the user (pt-BR): *"Todas as tarefas desta spec estao concluidas! Verifique se ha specs abertas em outras features."*
  - Stop.
- If found: show the task in chat and ask (pt-BR): *"Vou executar: **{task title}**. Posso prosseguir? (sim / nao)"*

### 3. Read plan and spec context

`Read` the `plan.md` and `spec.md` from the same NNN folder. Use as design and scope context.

### 4. Implement

- Write production code in **English** (variable names, comments, log messages).
- Follow architecture defined in `constitution.md` and `plan.md`.
- Write or update automated tests when the task requires it.
- Do not write code outside the scope of the current task.

### 5. Run tests

Execute the project's local automated tests:

| Stack | Command |
|---|---|
| .NET | `dotnet test` |
| Node.js | `npm test` |
| Python | `pytest` |
| Other | Use the runner detected in `constitution.md` or ask the user |

If tests fail:
- Fix before marking the task as complete.
- If unable to fix: report the error to the user before stopping.

### 6. Update tasks.md

After implementation validated by tests:

1. `Read` the `tasks.md` at the resolved destination.
2. Replace `- [ ] **Task N**` with `- [x] **Task N**` for the completed task.
3. `Write` the updated `tasks.md`.
4. Confirm in chat (pt-BR): *"Tarefa `{title}` marcada como concluida em `{path to tasks.md}`."*

### 7. Suggest commit

Generate a conventional commit suggestion:

```
feat(<scope>): <short description of the change>

<optional body with details>

Refs: .specify/specs/NNN-<slug>/spec.md
```

Ask the user (pt-BR): *"Deseja que eu execute o commit agora com `use skill commit`? (sim / nao)"*

## STOP - Session end (mandatory)

After completing one task, stop the session and hand off only. Do not implement another task in the same session unless the user explicitly requests it.

## Must not

- Write code in Portuguese
- Create new `spec.md`, `plan.md`, or `tasks.md` in this session
- Mark a task as complete without running tests
- Implement more than one task per session (unless the user explicitly requests it)
- Modify `constitution.md` during implementation
- **AI co-author trailers** - in any form. Under NO circumstances should you include `Co-authored-by: Cursor <cursoragent@cursor.com>` or any other AI agent attribution in commit messages.

## Handoff

```
use skill speckit-develop - {path to tasks.md}    (for the next task)
use skill commit                                    (to commit changes)
```
