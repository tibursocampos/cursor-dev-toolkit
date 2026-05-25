---
description: SDD agent artifacts (PRD, PLAN) in Brazilian Portuguese by default; code always English
alwaysApply: true
---

# SDD artifact language — pt-BR (agent workflow only)

## Scope (read first)

| In scope | Out of scope |
|----------|--------------|
| `PRD/*.md`, `docs/PRD/*.md`, global `~/.cursor/sdd/<repo-id>/PRD/*.md` | Source code, tests, configs |
| `PLAN/PLAN_*.md`, global `~/.cursor/sdd/<repo-id>/PLAN/PLAN_*.md` | Commit messages |
| Progress, step notes, checkboxes inside those PLAN files | Project `docs/`, README, ADRs (ask user) |

This rule does **not** change code language. It does **not** default project documentation to pt-BR.

## SDD artifacts — default pt-BR

Write **section titles**, **metadata labels**, **prose**, **acceptance criteria** (Dado/Quando/Então/E), **PLAN steps**, and **implementation notes** in **Brazilian Portuguese (pt-BR)**.

- Use templates in `~/.cursor/skills/spec/reference.md` and `~/.cursor/skills/plan/reference.md` (pt-BR variant).
- Do **not** write PRD/PLAN body in English unless the user overrides in the **same skill invocation** (see below).

**Identifiers in prose:** type names, method names, API routes, file paths, and test names stay in **English** (e.g. `UserService`, `Should_ReturnOk_When_ValidRequest`).

**No implementation code** in PRD/PLAN bodies (existing skill boundaries). If a minimal illustrative snippet is unavoidable, syntax and identifiers remain **English**.

## Code — always English

Any code generated or edited in the repository: **English** identifiers, comments, XML docs, commit messages, and test names `Should_<Result>_When_<Condition>`.

This rule does not grant an exception for “artifact in English” on code.

## Project documentation — ask

When `spec`, `plan`, or `implement` will create or change **product** documentation under `docs/`, README, or similar (not PRD/PLAN agent files), **ask once** before writing:

```
Em qual idioma gravar a documentação do sistema (docs/, README)?

1) Português (pt-BR)
2) Inglês (English)
```

Record the choice in the PLAN step or PRD notes if relevant. Do not assume pt-BR from this rule.

## Override — SDD artifact in English only

Apply only when the user explicitly requests it in the **same** prompt that invokes the skill (case-insensitive), for example:

- `em inglês`, `no inglês`, `in english`, `english only`
- `PRD em inglês`, `PLAN em inglês`, `write PRD in English`

Then write the **SDD `.md` artifact** in English using the English template sections in `reference.md` (if documented) or equivalent structure. Confirm in one chat line. Code remains English.

Set `artifact_language` to `"en"` in `~/.cursor/sdd/<repo-id>/manifest.json` when using global storage.

## Skills and conflicts

| Skill | Behavior |
|-------|----------|
| `spec` | New PRD → pt-BR unless override |
| `plan` | New PLAN → pt-BR unless override; read existing PRD in any language |
| `implement` | Code → English; update PLAN in **existing file language** |

This rule overrides conflicting lines in `AGENTS.md` or old templates **only for SDD agent `.md` files** listed above.

## Install path

After `scripts/sync-cursor.ps1`: `~/.cursor/rules/sdd-artifact-language-pt-br.mdc`
