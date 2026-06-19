---
name: speckit-plan
description: >
  Gera o plano de desenvolvimento técnico (plan.md) e lista de tarefas (tasks.md)
  com base em uma spec.md existente. Use para planejar speckit, criar plano, ou /speckit-plan.
---

# Skill: speckit-plan

## Trigger

Invoke when the user asks for: `use skill speckit-plan`, `planejar speckit`, `criar plano spec kit`, or `/speckit-plan`.

## Outcome

Two artifacts written to `.specify/specs/NNN-<slug>/`:
- `plan.md` — detailed technical design, affected files, scope.
- `tasks.md` — atomic checklist with checkboxes (`- [ ]`), tasks of 20–45 min each.

Both in **pt-BR**. Paths and technical identifiers in **English**.

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Storage resolution and manifest | `_shared/sdd-artifacts/STORAGE.md` § Global Manifest and Dynamic Storage Resolution |
| Path validation and confirm gate | `_shared/sdd-artifacts/PIPELINE.md` § Spec Kit path validation |
| Project architecture rules | `.specify/memory/constitution.md` (at resolved destination) |
| .NET / C# context if relevant | `_shared/dotnet-guidelines/clean-architecture.md` |
| Caveman Mode (if active) | `_shared/caveman/CAVEMAN.md` — **Lite mode** (only framing and introductions) |

## Process

### -1. Pipeline and storage

Load `STORAGE.md` § Resolution algorithm and `PIPELINE.md` § Spec Kit path validation. No production code or tests in this session.

Check `~/.cursor/sdd/preferences.json`:
- If file missing → create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` → load `_shared/caveman/CAVEMAN.md` (**Lite mode** rules only) and display:
  > 🪨 Modo Caveman ativo (respostas compactas — Lite). Digite `caveman off` a qualquer momento para desativar.
- In Lite mode: compress only framing and introductions. Plan/tasks drafts, confirmation gates `(sim / ajustar / cancelar)`, and clarifying questions are **never** compressed.
- Honor `caveman on` / `caveman off` at any point during the session.

### 1. Resolve spec.md

The user should provide the spec path (handoff from `speckit-spec`) or it will be resolved via glob:

```
Glob: {destination}/.specify/specs/*/spec.md
```

| Situation | Action |
|---|---|
| Path provided in handoff | `Read` directly |
| Multiple specs found | List them and ask which one (pt-BR, numbered) |
| No spec found | Inform user and redirect to `speckit-spec` |

Read the spec. Verify status **Pronto para planejamento**. If the status differs, warn the user and ask whether to proceed.

### 2. Load constitution

`Read` `.specify/memory/constitution.md` at the resolved destination.
- If it does not exist: proceed without it (warn in chat).

### 3. Draft technical plan

Based on the spec and constitution:

- Identify files to create/modify (paths in English).
- Propose technical approach respecting constitution constraints.
- Decompose into atomic steps of 20–45 min.
- Each step must be independently executable.

### 4. Generate drafts

**`plan.md`** — template (content in pt-BR, identifiers in English):

```markdown
# Plano: NNN — <Título>

## Spec de Referência
{path to spec.md}

## Design Técnico
<Abordagem e decisões arquiteturais>

## Arquivos Afetados
| Ação | Arquivo |
|---|---|
| CRIAR | path/to/file |
| MODIFICAR | path/to/file |

## Escopo
### Incluso
- <item>

### Excluído
- <item>

## Riscos
- <risco>

## Status
0/{N} tarefas concluídas
```

**`tasks.md`** — template (content in pt-BR, identifiers in English):

```markdown
# Tasks: NNN — <Título>

## Referências
- Spec: {path to spec.md}
- Plan: {path to plan.md}

## Tarefas

- [ ] **Task 1** — <descrição clara em uma linha>
  - Contexto: <o que fazer e por que>
  - Arquivos: <file1>, <file2>

- [ ] **Task 2** — <descrição>
  ...
```

### 5. Confirm before write

Show: title, `NNN`, **absolute paths** of both files, storage mode, task count.
Ask the user (pt-BR): **"Posso gravar `plan.md` e `tasks.md` em `{folder}`? (sim / ajustar / cancelar)"**

### 6. Write (after sim)

1. Validate both paths per `PIPELINE.md` § Spec Kit path validation — abort if invalid.
2. `Write` to `plan.md`.
3. `Write` to `tasks.md`.
4. Report: written paths, number of tasks.

## Must not

- Create or modify `spec.md` in this session
- Write production code or tests
- Skip confirmation before writing
- Use an NNN different from the source spec

## Handoff

```
use skill speckit-develop — {path to tasks.md}
```
