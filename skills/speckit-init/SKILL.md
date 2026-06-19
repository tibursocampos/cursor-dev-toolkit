---
name: speckit-init
description: >
  Inicializa a estrutura do Spec Kit (.specify/) no repositório ativo ou na pasta
  global de SDD configurada, gerando uma constituição pré-preenchida inteligente baseada no seu stack.
  Use para inicializar o speckit ou /speckit-init.
---

# Skill: speckit-init

## Trigger

Invoke when the user asks for: `use skill speckit-init`, `inicializar speckit`, `init spec kit`, or `/speckit-init`.

## Outcome

`.specify/` structure created at the resolved destination (local repository or global directory), and `.specify/memory/constitution.md` automatically configured with intelligent principles tailored to the detected tech stack of the project.

## Lazy-load (only when needed)

| When | Path |
|------|------|
| Storage resolution and manifest | `_shared/sdd-artifacts/STORAGE.md` § Global Manifest and Dynamic Storage Resolution |
| Repository guidelines scan | `_shared/developer-common/GUIDE.md` |
| | `_shared/code-guidelines/principles/` |
| | `_shared/dotnet-guidelines/` |

## Process

### -1. Check prerequisites

Run: `specify --version`

- If the command fails:
  - Inform the user (pt-BR): *"A CLI do Spec Kit não foi encontrada. Execute primeiro: `use skill speckit-setup`."*
  - Stop.

### 1. Resolve storage

Load `STORAGE.md` § Resolution algorithm. Identify `storage_mode` and `path` for the active repository (`$Cwd`). If first run on this repo: execute the storage mode selection flow.

### 2. Check for existing `.specify/`

Check whether `.specify/` already exists at the resolved destination.

- **Already exists**: inform the user (pt-BR):
  > *"A estrutura `.specify/` já existe em `{destino}`. Não vou sobrescrever uma configuração existente. Encerrando."*
  — stop.
- **Does not exist**: proceed.

### 3. Initialize via CLI

| storage_mode | Command |
|---|---|
| `repository` | `specify init . --integration generic --integration-options="--commands-dir .specify/commands/" --force` |
| `global` | Create `{path}` if it does not exist, then run `specify init {path} --integration generic --integration-options="--commands-dir .specify/commands/" --force` |

If the command fails:
- Display the error output in chat.
- Suggest verifying the installation with `specify --version`.

### 3.5. Smart Constitution Pre-fill

After successfully initializing the project structure, the agent must perform a static analysis of the workspace (`$Cwd`) in parallel using subagents (if necessary) to detect the stack and pre-fill the constitution.

1. **Concurrently Scan the Repository**:
   List files in `$Cwd` and subdirectories in parallel to identify the tech stack:
   - Presence of any `.csproj` or `.sln` -> Technology: **.NET / C#**
   - Presence of `package.json` -> Technology: **Node.js/JS/TS**
     - Parse `package.json` or check `angular.json` for `@angular/` -> Technology: **Angular**
     - Parse `package.json` for `react` -> Technology: **React**
   - Presence of `requirements.txt`, `pyproject.toml`, `Pipfile`, `setup.py` -> Technology: **Python**
   - Presence of `plugin.json` or `.ps1` -> Technology: **PowerShell / Antigravity Plugin**

2. **Load Shared Guidelines Concurrently**:
   In parallel, read the following:
   - `_shared/developer-common/GUIDE.md`
   - `_shared/code-guidelines/principles/` (SOLID.md, DRY.md, KISS.md, YAGNI.md)
   - If **.NET / C#** is detected: read `_shared/dotnet-guidelines/clean-architecture.md` and `_shared/dotnet-guidelines/csharp-patterns.md`

3. **Draft Tailored Principles**:
   Consolidate findings and write a customized `.specify/memory/constitution.md` replacing placeholders:
   - **Core Principles**: Add up to 5 principles mapping to the detected technologies and shared rules (e.g. Clean Architecture for .NET, strict localization/chat language rules, conventional commits without agent attribution footer).
   - **Constraints & Governance**: Add specific constraints regarding build tools and Git flow blockages.

4. **Verify and Write**:
   - Only overwrite the placeholder file if it only contains the default placeholders (e.g. `[PRINCIPLE_1_NAME]`). If the user already custom-wrote the constitution, do not touch it.
   - Inform the user in chat (pt-BR) about the detected stacks and the principles configured.

### 4. Validate result

Check whether `.specify/memory/constitution.md` exists and contains the custom-written principles.

- **Yes**: confirm in chat (pt-BR):
  > *"✅ Spec Kit inicializado em `{destino}`. A constitution inteligente foi gerada e está em `{destino}/.specify/memory/constitution.md`."*
- **No**: warn in chat (pt-BR):
  > *"⚠️ A inicialização completou mas `constitution.md` não foi encontrado. Verifique o diretório manualmente."*

## Must not

- Overwrite an existing custom `.specify/memory/constitution.md` file
- Initialize without confirming the write destination
- Run `specify init` without checking prerequisites
- Use blocking/sequential file-reading when parallel scan is possible

## Handoff

```
use skill speckit-spec
```
