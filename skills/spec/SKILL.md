---
name: spec
description: Create a PRD for a new feature or change. Writes agent PRD .md in pt-BR by default (repo or ~/.cursor/sdd/<repo-id>/). Use when the user says "use skill spec", "create spec", "new feature", or "/spec". Output feeds the plan skill.
---

# Skill: spec

## Trigger

Invoke when the user asks for: `use skill spec`, `create spec`, `new feature`, or `/spec`.

## Outcome

A complete **PRD** (agent `.md` artifact) in **Brazilian Portuguese (pt-BR)** at a **canonical** path (`PRD/`, `docs/PRD/`, or `~/.cursor/sdd/<repo-id>/PRD/`). English only if the user overrides in this invocation. Mandatory input for **plan**.

## PRD boundaries

The PRD answers **what**, not **how**. No implementation code. Identifiers (types, APIs, paths) in **English**.

## Lazy-load (only when needed)

| When | Path (after sync) |
|------|-------------------|
| Pipeline guards, modes, confirm, paths | `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md` |
| Storage, manifest, `.gitignore` | `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md` |
| Caveman Mode (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` — **Lite mode** |
| SDD artifact language | `~/.cursor/rules/sdd-artifact-language-pt-br.mdc` |
| .NET / C# context | `dotnet-guidelines/clean-architecture.md`, `csharp-patterns.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### -1. Pipeline and mode

Load `PIPELINE.md`. Apply Phase A/B: in Plan/Ask, draft in chat only until Agent + user **sim** on § Confirm below. Pipeline lock: no PLAN, no `Edit`/`Write` on `*.cs`, `*.csproj`, migrations.

Check `~/.cursor/sdd/preferences.json`:
- If file missing → create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` → load `~/.cursor/skills/_shared/caveman/CAVEMAN.md` (**Lite mode** rules only) and display:
  > 🪨 Modo Caveman ativo (respostas compactas — Lite). Digite `caveman off` a qualquer momento para desativar.
- Honor `caveman on` / `caveman off` at any point during the session.

### 0. Workspace

Target repo (not `cursor-dev-toolkit` unless subject). Read `AGENTS.md` / `README.md`. Detect stack. Resolve `<repo-id>`; glob PRDs (workspace + global) for `NNN`.

### 1. Requirements

**Prior context** (chat, code-review, backlog): structured summary + max **3** gap questions — skip full questionnaire (`PIPELINE.md` § Prior context).

**Otherwise** ask (pt-BR):

```
Vou criar o PRD. Informe:
1) Feature — o que construir ou alterar?
2) Comportamento atual
3) Comportamento esperado
4) Contexto adicional (opcional)
5) ID de rastreamento (opcional)
```

Wait for answers.

### 2–5. Confirm repo, explore code, clarify (≤5), technical analysis

Per existing skill intent: branch confirmation, Glob/Grep/Read, brief impact/risks for the PRD.

### 6. Context checkpoint

`context-management.mdc`. At ≥40%, draft in chat or partial file; warn before continuing.

### 6.5 Storage

`STORAGE.md`: manifest or storage prompt; record `artifact_language` (default pt-BR).

### 6.75 Confirm before write

`PIPELINE.md` § Confirm before write — title, `NNN`, **full canonical path**, storage, bullets, status **Pronto para planejamento**. Wait for **sim** / **ajustar** / **cancelar**. In Plan/Ask without **sim** in Agent: Phase A message only.

### 7. Write PRD (Agent + sim only)

1. Validate path per `PIPELINE.md` § Path validation — abort if non-canonical.
2. Repository mode: `.gitignore` per `STORAGE.md` (all four patterns).
3. `NNN_short_feature_slug.md`; body from `reference.md`.
4. Product `docs/` in scope: ask doc language first.

Report path, storage, language, `.gitignore` changes. Handoff: `use skill plan — <full-prd-path>`.

## Must not

- English PRD body by default; implementation code in PRD
- `Write` outside canonical PRD folders; skip confirm-before-write
- `Edit`/`Write` production or test code; create PLAN in this session
- Claim “PRD saved” without successful `Write`
- External trackers; paste full guideline bodies into PRD

## Handoff

```
use skill plan — <full-prd-path>
```
