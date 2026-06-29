---
name: speckit-spec
description: >
  Create spec.md under .specify/specs/NNN-slug/ at resolved storage path.
  Use when the user says "use skill speckit-spec", "create speckit spec", or "/speckit-spec".
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

Invoke when the user asks for: `use skill speckit-spec`, `criar spec speckit`, `nova spec`, or `/speckit-spec`.

## Outcome

A complete `spec.md` in **pt-BR** written to `.specify/specs/NNN-<slug>/spec.md` at the resolved destination (local or global). Mandatory input for `speckit-plan`.

## Spec boundaries

The spec answers **what** and **why**, not **how**. No implementation code. Identifiers (types, APIs, paths) in **English**.

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Storage schema v2 and manifest | `_shared/sdd-artifacts/STORAGE.md` section Global Manifest and Dynamic Storage Resolution |
| Path validation and confirm gate | `_shared/sdd-artifacts/PIPELINE.md` section Spec Kit path validation |
| Extended template (optional) | `reference.md` (this skill) |
| Caveman Mode (if active) | `_shared/caveman/CAVEMAN.md` - **Lite mode** (only framing and introductions) |

## Process

### -1. Validate speckit initialization

Run `scripts/validation/validate-speckit-init.ps1` before any spec workflow action.
- If validation fails: **STOP** and handoff to `use skill speckit-init`.
- If validation passes: continue.

### 0. Pipeline and storage

Load `STORAGE.md` and `PIPELINE.md`. Use `STORAGE.md` schema v2 and run the dynamic storage resolution algorithm with parameter `$Workflow = speckit`. No `Write` without explicit **sim** from the user.

Check `~/.cursor/sdd/preferences.json`:
- If file missing -> create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` -> load `_shared/caveman/CAVEMAN.md` (**Lite mode** rules only) and display:
  > Modo Caveman ativo (respostas compactas - Lite). Digite `caveman off` a qualquer momento para desativar.
- In Lite mode: compress only framing and introductions. Spec drafts, confirmation gates (`sim / ajustar / cancelar`), and clarifying questions are **never** compressed.
- Honor `caveman on` / `caveman off` at any point during the session.

### 1. Workspace

Confirm target repository. Read `.specify/memory/constitution.md` when present (project rules and preferences).

### 2. Determine next NNN

```
List: {destination}/.specify/specs/*/
Count existing folders.
NNN = (highest existing index) + 1, zero-padded to 3 digits (001, 007, 042).
If no folder exists: NNN = 001.
```

### 3. Collect requirements

**Prior context** (requirements, code, review): provide a structured summary plus at most **3** gap questions - skip full questionnaire.

**Otherwise**, ask the user (pt-BR):

```
Vou criar a spec. Informe:
1) Feature - o que construir ou alterar?
2) Comportamento atual
3) Comportamento esperado
4) Contexto adicional (opcional)
```

Wait for answers before proceeding.

### 4. Generate slug and path

```
slug = <title in ASCII kebab-case, max 40 characters>
path = {destination}/.specify/specs/NNN-{slug}/spec.md
```

### 5. Draft the spec

Produce `spec.md` in pt-BR following the official Spec Kit template:

```markdown
# NNN - <Titulo da Feature>

## Contexto e Motivacao
<Por que esta feature e necessaria?>

## Comportamento Atual
<O que acontece hoje?>

## Comportamento Esperado
<O que deve acontecer apos a implementacao?>

## Criterios de Aceitacao
- [ ] <criterio 1>
- [ ] <criterio 2>

## Fora do Escopo
<O que explicitamente nao sera feito>

## Riscos e Consideracoes
<Riscos tecnicos ou de negocio>

## Status
Pronto para planejamento
```

### 6. Confirm before write

Show title, `NNN`, **absolute path**, storage mode, and content bullets.
Ask the user (pt-BR): **"Posso gravar em `{path}`? (sim / ajustar / cancelar)"**

### 7. Write (after sim)

1. Validate path per `PIPELINE.md` section Spec Kit path validation regex - abort if invalid.
2. Create folder `{destination}/.specify/specs/NNN-{slug}/` if it does not exist.
3. `Write` to `spec.md`.
4. Report written path, NNN, and storage mode.

## Must not

- Write without explicit user confirmation (**sim**)
- Use a path outside the `.specify/specs/NNN-<slug>/` structure
- Include implementation code in the spec
- Create `plan.md` or `tasks.md` in this session

## Handoff

```
use skill speckit-plan - {written path}
```
