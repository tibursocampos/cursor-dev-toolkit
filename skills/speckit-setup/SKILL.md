---
name: speckit-setup
description: >
  Configura e instala todas as dependências do GitHub Spec Kit (Python, uv, specify-cli)
  e pastas globais no Windows. Use quando solicitado setup de dependências ou /speckit-setup.
---

# Skill: speckit-setup

## Trigger

Invoke when the user asks for: `use skill speckit-setup`, `setup speckit`, `instalar spec kit`, or `/speckit-setup`.

## Outcome

Environment ready for Spec Kit skills: Python 3.10+, `uv`, and `specify-cli` installed and accessible in PATH. Global directories initialized at `$env:USERPROFILE\.cursor\sdd\`.

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Storage resolution and manifest | `_shared/sdd-artifacts/STORAGE.md` § Global Manifest |

## Process

### 1. Check Python

Run: `python --version`

- **Success** (3.10+): proceed to step 2.
- **Failure** (command not found or version < 3.10):
  - Ask the user (pt-BR):
    > *"O Python 3.10+ não foi encontrado no PATH. Deseja que eu tente instalá-lo automaticamente via winget? (sim / não)"*
  - If **sim**: run `winget install -e --id Python.Python.3.12`
    - If it fails: show the manual instructions below and stop.
  - If **não** or failure: show and stop:
    > *"Não consegui instalar o Python automaticamente (falha no comando ou falta de permissão administrativa).*
    > *Por favor, resolva manualmente:*
    > *1. Abra o terminal como **Administrador** e rode: `winget install -e --id Python.Python.3.12`*
    > *2. Ou baixe o instalador oficial: https://www.python.org/downloads/*"

### 2. Check `uv`

Run: `uv --version`

- **Success**: proceed to step 3.
- **Failure**:
  - Ask the user (pt-BR):
    > *"O gerenciador 'uv' não foi encontrado. Deseja que eu execute a instalação? (sim / não)"*
  - If **sim**: run `powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"`
    - If it fails: show manual instructions below and stop.
  - If **não** or failure: show and stop:
    > *"Por favor, instale o `uv` manualmente executando este comando no terminal:*
    > ```powershell
    > powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
    > ```"

### 3. Install `specify-cli`

Run: `specify --version`

- **Success**: proceed to step 4.
- **Failure**:
  - Run: `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git --force`
  - If it fails: show the command above in the chat and ask the user to run it locally.

### 4. Initialize global directories

1. Check if `$env:USERPROFILE\.cursor\sdd\` exists. If not, create it.
2. Check if `$env:USERPROFILE\.cursor\sdd\manifest.json` exists. If not, create it with:
   ```json
   {"repositories": {}}
   ```
3. Confirm in chat (pt-BR):
   > *"✅ Setup do Spec Kit concluído. Todos os pré-requisitos estão instalados e o diretório global de SDD foi inicializado."*

## Must not

- Assume Python or `uv` are available without checking
- Skip the confirmation prompt before running installers (`winget`, `uv install`)
- Fail silently — always show manual instructions on failure

## Handoff

```
use skill speckit-init
```
