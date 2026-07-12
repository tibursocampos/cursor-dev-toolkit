---
name: containerize
description: Write multi-stage Dockerfiles, .dockerignore, and docker-compose for local dev. Use when dockerizing a project or invoking /containerize.
---


## STOP - Read before ANY tool call

1. Read `~/.cursor/rules/guardrails.mdc`
2. Read `~/.cursor/skills/_shared/sdd-artifacts/SESSION.md`; load session-state for `$Cwd`
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

# Skill: containerize

## Trigger

Invoke when the user requests: `/containerize`, `dockerize project`, `/containerize`, or asks to containerize the workspace.

**Arguments (optional):**

| Input | Meaning |
|-------|---------|
| Runtime port | The primary network port to expose in the container |

## Outcome

A set of production-ready container configurations:

1. **Dockerfile:** Multi-stage build leveraging minimal base images (alpine or distroless), strict layer caching, and non-root execution.
2. **.dockerignore:** Clean file excluding local packages, builds, git, and sensitive secrets.
3. **docker-compose.yml:** Orchestrated configuration for local testing, binding the application port and spinning up required database/caching services.

## Lazy-load

| When | Path (after `scripts/sync-cursor.ps1`) |
|------|----------------------------------------|
| DevOps context | `~/.cursor/skills/_shared/devops-guidelines/deployment-process.md` |
| Caveman Mode (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` - Full mode |

## Process

### -1. Re-check guardrails and session

Confirm `guardrails.mdc` and `SESSION.md` are loaded.
If missing, ask user (pt-BR):

```text
Antes de containerizar, confirme:
- guardrails.mdc lido
- SESSION.md carregado

Posso seguir? (sim / ajustar / cancelar)
```

### -2. Caveman Mode Check

Check `~/.cursor/sdd/preferences.json`:
- If file missing -> create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` -> load `~/.cursor/skills/_shared/caveman/CAVEMAN.md` and honor active compressions.

### 0. Workspace Inspection

* Identify the programming language/platform (C#, Node.js, Python, static frontend).
* Scan for configuration files (`appsettings.json`, `.env`, `package.json`, `requirements.txt`) to determine:
  * Excluded files and build outputs.
  * Internal network ports.
  * Dependent services (e.g., PostgreSQL, MS SQL, Redis, RabbitMQ).

### 1. Draft the Configuration & Workflow Decision

* Explain the proposed container strategy:
  * Base images to use (e.g. `mcr.microsoft.com/dotnet/aspnet:8.0-alpine` or `node:20-alpine`).
  * Port maps and network parameters.
  * Required local services in compose.
* Stop and ask the user to choose the workflow execution path to build and verify these configurations:
  * **Option A - Direct Developer Skill (`/developer`):** For straightforward local creation of Dockerfiles/Compose.
  * **Option B - Classic SDD (`/sdd-spec` -> `sdd-plan` -> `sdd-develop`):** For complex environment containerization requiring formal specifications (PRD) and a detailed plan (PLAN) in Portuguese.
  * **Option C - Spec Kit (`/speckit-spec` -> `speckit-plan` -> `speckit-develop`):** For repositories initialized with Spec Kit.
  * **Option D - Plain Chat Plan:** Establish a simple task list directly in the chat, executing steps one by one without extra file creations.
* **Wait for explicit user choice** before writing code or initializing another workflow.

### 2. Generate Dockerfile

* Write `Dockerfile` using multi-stage build patterns:
  * **Build stage:** Copy package manifests (`.csproj`, `package.json`, `requirements.txt`) and restore first to leverage layer caching. Then copy code and compile.
  * **Runtime stage:** Copy only build artifacts from the build stage.
  * Enforce security: create and switch to a non-root system user inside the runtime image.
  * Define `EXPOSE` and a stable `ENTRYPOINT` or `CMD`.

### 3. Generate .dockerignore

* Write `.dockerignore`. Standard exclusions:
  * Dotnet: `**/bin`, `**/obj`, `**/.vs`, `**/.git`, `*.user`.
  * Node: `node_modules`, `npm-debug.log`, `dist`, `build`.
  * Python: `__pycache__`, `*.pyc`, `*.pyo`, `*.pyd`, `.venv`, `.env`.

### 4. Generate docker-compose.yml

* Write `docker-compose.yml` for local development:
  * Declare the application service built from the local `Dockerfile`.
  * Declare secondary database or cache services identified in step 0.
  * Configure persistent volumes for database data.
  * Setup environment variables to link the application with the companion services.

### 5. Local Syntax Validation

* Validate file formats (ensure correct YAML spacing in compose).
* Recommend the user run a local test build:

```bash
docker compose build
docker compose up -d
```

### 6. Handoff

* Offer committing the configurations:

```
/commit
```

## Must not

* Use heavy, development-only base images for runtimes.
* Expose sensitive environment variables, tokens, or credentials inside checked-in files. Use env templates or volumes.
