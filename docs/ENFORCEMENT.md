# Enforcement Architecture - Cursor toolkit

This document explains how cursor-dev-toolkit enforces guardrails and how that differs from Antigravity IDE.

## Cursor advantages (native enforcement)

| Layer | Mechanism | Effect |
|-------|-----------|--------|
| **Always-on rules** | `~/.cursor/rules/*.mdc` with `alwaysApply: true` | Guardrails visible every conversation |
| **Hooks** | `beforeSubmitPrompt`, `afterFileEdit`, `preCompact` | Skill tracking, PLAN/tasks edit state, context warnings |
| **Branch validation** | `branch-validation.mdc` | Blocks commit/push on invalid branch names |
| **Shell** | User approval in Cursor for terminal commands | Partial block on mutating git |

## Mitigation layers (this toolkit)

1. **`guardrails.mdc`** - compact STOP rules (git, write, one step, tests, language)
2. **`sdd-pipeline-guards.mdc`** - SDD order, paths, confirm-before-write
3. **`SESSION.md` + session-state** - verifiable gates in `~/.cursor/sdd/sessions/{repo-hash}.json`
4. **Gate-first Step -1** on every skill
5. **Validation scripts** - `validate-all.ps1` smoke test after sync

## vs Antigravity

| Layer | Antigravity | Cursor |
|-------|-------------|--------|
| Always-on rules | KI `global_guardrails` | `guardrails.mdc` + other rules |
| Skill discovery | KI on explicit invoke | User skills + rules |
| Session gates | Same schema, different path | `~/.cursor/sdd/sessions/` |
| Smoke test | `validate-all.ps1` | Same pattern, checks rules/hooks not KIs |

## Limitations

Without modifying consumer repositories, there is no 100% block on agent file writes. Enforcement relies on rules + session gates + skill discipline + optional hooks.

## After sync

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validate-all.ps1
```

Restart Cursor or reload hooks if `hooks.json` changed.
