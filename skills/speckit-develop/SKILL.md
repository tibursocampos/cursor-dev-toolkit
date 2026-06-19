---
name: speckit-develop
description: >
  Implementa um passo do checklist tasks.md gerado pelo Spec Kit.
  Use para desenvolver speckit, executar tarefa speckit, ou /speckit-develop.
---

# Skill: speckit-develop

## Trigger

Invoke when the user asks for: `use skill speckit-develop`, `executar tarefa speckit`, `desenvolver spec kit`, or `/speckit-develop`.

## Outcome

Production code and/or tests written (in **English**) for one pending task from `tasks.md`. The `tasks.md` file updated with the task marked as complete (`- [x]`).

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Storage resolution and manifest | `_shared/sdd-artifacts/STORAGE.md` § Global Manifest and Dynamic Storage Resolution |
| Project architecture rules | `.specify/memory/constitution.md` (at resolved destination) |
| .NET / C# rules | `_shared/dotnet-guidelines/clean-architecture.md`, `_shared/dotnet-guidelines/csharp-patterns.md` |
| General code guidelines | `_shared/code-guidelines/` (based on detected stack) |
| Caveman Mode (if active) | `_shared/caveman/CAVEMAN.md` — Full mode |

## Process

### -1. Load context

Resolve storage per `STORAGE.md`. `Read` `.specify/memory/constitution.md` — apply constraints. Load guidelines relevant to the project stack.

Check `~/.cursor/sdd/preferences.json`:
- If file missing → create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` → load `_shared/caveman/CAVEMAN.md` (Full mode rules) and display:
  > 🪨 Modo Caveman ativo (respostas compactas). Digite `caveman off` a qualquer momento para desativar.
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
  - Inform the user (pt-BR): *"Todas as tarefas desta spec estão concluídas! 🎉 Verifique se há specs abertas em outras features."*
  - Stop.
- If found: show the task in chat and ask (pt-BR): *"Vou executar: **{task title}**. Posso prosseguir? (sim / não)"*

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
4. Confirm in chat (pt-BR): *"✅ Tarefa `{title}` marcada como concluída em `{path to tasks.md}`."*

### 7. Suggest commit

Generate a conventional commit suggestion:

```
feat(<scope>): <short description of the change>

<optional body with details>

Refs: .specify/specs/NNN-<slug>/spec.md
```

Ask the user (pt-BR): *"Deseja que eu execute o commit agora com `use skill commit`? (sim / não)"*

## Must not

- Write code in Portuguese
- Create new `spec.md`, `plan.md`, or `tasks.md` in this session
- Mark a task as complete without running tests
- Implement more than one task per session (unless the user explicitly requests it)
- Modify `constitution.md` during implementation
- **AI co-author trailers** — in any form. Under NO circumstances should you include `Co-authored-by: Cursor <cursoragent@cursor.com>` or any other AI agent attribution in commit messages.

## Handoff

```
use skill speckit-develop — {path to tasks.md}    (for the next task)
use skill commit                                    (to commit changes)
```
