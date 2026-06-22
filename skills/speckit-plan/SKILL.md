---
name: speckit-plan
description: >
  Generate plan.md and tasks.md from an existing spec.md under Spec Kit layout.
  Use when the user says "use skill speckit-plan", "create speckit plan", or "/speckit-plan".
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

Invoke when the user asks for: `use skill speckit-plan`, `planejar speckit`, `criar plano spec kit`, or `/speckit-plan`.

## Outcome

Two artifacts written to `.specify/specs/NNN-<slug>/`:
- `plan.md` - detailed technical design, affected files, scope.
- `tasks.md` - atomic checklist with checkboxes (`- [ ]`), tasks of 20-45 minutes each.

Both in **pt-BR**. Paths and technical identifiers in **English**.

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Storage schema v2 and manifest | `_shared/sdd-artifacts/STORAGE.md` section Global Manifest and Dynamic Storage Resolution |
| Path validation and confirm gate | `_shared/sdd-artifacts/PIPELINE.md` section Spec Kit path validation |
| Project architecture rules | `.specify/memory/constitution.md` (at resolved destination) |
| .NET / C# context (if needed) | `_shared/dotnet-guidelines/clean-architecture.md` |
| Extended templates (optional) | `reference.md` (this skill) |
| Caveman Mode (if active) | `_shared/caveman/CAVEMAN.md` - **Lite mode** (only framing and introductions) |

## Process

### -1. Validate speckit initialization

Run `scripts/validate-speckit-init.ps1` before any plan workflow action.
- If validation fails: **STOP** and handoff to `use skill speckit-init`.
- If validation passes: continue.

### 0. Pipeline and storage

Load `STORAGE.md` and `PIPELINE.md`. Use `STORAGE.md` schema v2 and run the dynamic storage resolution algorithm with parameter `$Workflow = speckit`. Do not write production code or tests in this session.

Check `~/.cursor/sdd/preferences.json`:
- If file missing -> create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` -> load `_shared/caveman/CAVEMAN.md` (**Lite mode** rules only) and display:
  > Modo Caveman ativo (respostas compactas - Lite). Digite `caveman off` a qualquer momento para desativar.
- In Lite mode: compress only framing and introductions. Plan/tasks drafts, confirmation gates (`sim / ajustar / cancelar`), and clarifying questions are **never** compressed.
- Honor `caveman on` / `caveman off` at any point during the session.

### 1. Resolve spec.md

The user should provide the spec path (handoff from `speckit-spec`) or it will be resolved via glob:

```
Glob: {destination}/.specify/specs/*/spec.md
```

| Situation | Action |
|---|---|
| Path provided in handoff | `Read` directly |
| Multiple specs found | List and ask user (pt-BR) to pick one (numbered) |
| No spec found | Inform user and redirect to `speckit-spec` |

Read the spec. Validate status **Pronto para planejamento**. If status differs, warn and ask whether to proceed.

### 2. Load constitution

`Read` `.specify/memory/constitution.md` at the resolved destination.
- If missing: proceed and warn in chat.

### 3. Draft technical plan

Based on spec and constitution:
- Identify files to create/modify (paths in English).
- Propose approach aligned with constitution constraints.
- Decompose into atomic steps of 20-45 minutes.
- Ensure each step is independently executable.

### 4. Generate drafts

**`plan.md`** template (content in pt-BR, identifiers in English):

```markdown
# Plano: NNN - <Titulo>

## Spec de Referencia
{path to spec.md}

## Design Tecnico
<Abordagem e decisoes arquiteturais>

## Arquivos Afetados
| Acao | Arquivo |
|---|---|
| CRIAR | path/to/file |
| MODIFICAR | path/to/file |

## Escopo
### Incluso
- <item>

### Excluido
- <item>

## Riscos
- <risco>

## Status
0/{N} tarefas concluidas
```

**`tasks.md`** template (content in pt-BR, identifiers in English):

```markdown
# Tasks: NNN - <Titulo>

## Referencias
- Spec: {path to spec.md}
- Plan: {path to plan.md}

## Tarefas

- [ ] **Task 1** - <descricao clara em uma linha>
  - Contexto: <o que fazer e por que>
  - Arquivos: <file1>, <file2>

- [ ] **Task 2** - <descricao>
  ...
```

### 5. Confirm before write

Show title, `NNN`, **absolute paths** for both files, storage mode, and task count.
Ask the user (pt-BR): **"Posso gravar `plan.md` e `tasks.md` em `{folder}`? (sim / ajustar / cancelar)"**

### 6. Write (after sim)

1. Validate both paths per `PIPELINE.md` section Spec Kit path validation - abort if invalid.
2. `Write` `plan.md`.
3. `Write` `tasks.md`.
4. Report written paths and task count.

## Must not

- Create or modify `spec.md` in this session
- Write production code or tests
- Skip confirmation before writing
- Use an NNN different from the source spec

## Handoff

```
use skill speckit-develop - {path to tasks.md}
```
