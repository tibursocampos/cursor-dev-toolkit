---
name: speckit-setup
description: >
  Install Spec Kit dependencies (Python, uv, specify-cli) and global SDD directories on Windows.
  Use when the user says "use skill speckit-setup", "setup speckit", or "/speckit-setup".
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

# Skill: speckit-setup

## Trigger

Invoke when the user asks for: `use skill speckit-setup`, `setup speckit`, `instalar spec kit`, or `/speckit-setup`.

## Outcome

Environment ready for Spec Kit skills: Python 3.10+, `uv`, and `specify-cli` installed and accessible in PATH. Global directories initialized at `$env:USERPROFILE\.cursor\sdd\`.

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Storage resolution and manifest | `_shared/sdd-artifacts/STORAGE.md` section Global Manifest |

## Process

### 1. Check Python

Run: `python --version`

- **Success** (3.10+): proceed to step 2.
- **Failure** (command not found or version < 3.10):
  - Ask the user (pt-BR):
    > *"O Python 3.10+ nÃ£o foi encontrado no PATH. Deseja que eu tente instalÃ¡-lo automaticamente via winget? (sim / nÃ£o)"*
  - If **sim**: run `winget install -e --id Python.Python.3.12`
    - If it fails: show the manual instructions below and stop.
  - If **nÃ£o** or failure: show and stop:
    > *"NÃ£o consegui instalar o Python automaticamente (falha no comando ou falta de permissÃ£o administrativa).*
    > *Por favor, resolva manualmente:*
    > *1. Abra o terminal como **Administrador** e rode: `winget install -e --id Python.Python.3.12`*
    > *2. Ou baixe o instalador oficial: https://www.python.org/downloads/*"

### 2. Check `uv`

Run: `uv --version`

- **Success**: proceed to step 3.
- **Failure**:
  - Ask the user (pt-BR):
    > *"O gerenciador 'uv' nÃ£o foi encontrado. Deseja que eu execute a instalaÃ§Ã£o? (sim / nÃ£o)"*
  - If **sim**: run `powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"`
    - If it fails: show manual instructions below and stop.
  - If **nÃ£o** or failure: show and stop:
    > *"Por favor, instale o `uv` manualmente executando este comando no terminal:*
    > ```powershell
    > powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
    > ```"

### 3. Install `specify-cli`

Run: `specify --version`

- **Success**: proceed to step 4.
- **Failure**:
  - Run: `uv tool install specify-cli --from git+https://github.com/github/sdd-spec-kit.git --force`
  - If it fails: show the command above in the chat and ask the user to run it locally.

### 4. Initialize global directories

1. Check if `$env:USERPROFILE\.cursor\sdd\` exists. If not, create it.
2. Check if `$env:USERPROFILE\.cursor\sdd\manifest.json` exists. If not, create it with:
   ```json
   {"repositories": {}}
   ```
3. Confirm in chat (pt-BR):
   > *"âœ… Setup do Spec Kit concluÃ­do. Todos os prÃ©-requisitos estÃ£o instalados e o diretÃ³rio global de SDD foi inicializado."*

## Must not

- Assume Python or `uv` are available without checking
- Skip the confirmation prompt before running installers (`winget`, `uv install`)
- Fail silently - always show manual instructions on failure

## Handoff

```
use skill speckit-init
```
