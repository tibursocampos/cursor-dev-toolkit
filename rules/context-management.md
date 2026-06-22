---
description: Checkpoint multi-step SDD skills when context is high; persist PLAN/PRD before continuing
alwaysApply: true
---

# Context management

Avoid losing progress on long, multi-step work. This rule applies to **every** interaction when context pressure is visible, and **mandatory checkpoints** at the end of each step in multi-step skills.

## Universal - every response

When the environment shows context usage (status line, system reminder, or user-reported percentage):

| Usage | Status | Action |
|-------|--------|--------|
| **< 40%** | OK | Note usage briefly; continue normally |
| **≥ 40%** | Warning | Stop multi-step skills immediately; warn on other long tasks |
| **≥ 80%** | Critical | Stop immediately; do not continue in this session |

If usage is unknown, still **save artifacts to disk** at step boundaries (PLAN/PRD checkboxes, files written) when in **Agent** mode and the user has confirmed the write (`sdd-pipeline-guards.mdc` / `PIPELINE.md` § Confirm before write).

In **Plan/Ask**, persist progress in chat drafts until the user switches to Agent and confirms - do not claim PRD/PLAN were saved without `Write`.

Do not end a skill abruptly without persisting the control artifact (or an explicit paused draft with path pending).

## Multi-step skills - end of each step

For skills that run sequential steps against an external control file:

| Skill | Control artifact |
|-------|------------------|
| `sdd-spec` | `PRD/*.md`, `docs/PRD/*.md`, or global PRD path |
| `sdd-plan` | `PLAN/PLAN_*.md` or global PLAN path |
| `sdd-develop` | Same PLAN path as handoff (one step per session) |
| `speckit-spec` | `.specify/specs/NNN-<slug>/spec.md` |
| `speckit-plan` | same folder: `plan.md`, `tasks.md` |
| `speckit-develop` | same folder: `tasks.md` (one task per session) |
| `document-implement` | `docs/documentation-plan/plan.md` (one step per session) |

### Required flow after each completed step

1. **Persist progress** - update the control file (checkbox, status, notes).
2. **Assess context** - use visible usage or ask the user if unclear.
3. **Decide** using the table above.
4. If **≥ 40%**, pause and show:

```
EXECUTION PAUSED - Context at X% used.

This is a safety stop. Execution does not continue automatically.

Saved: [control file path]
Last step done: [step id - short description]
Next pending: [next step id - short description]

Recommended: start a new chat and resume from the control file.
To continue in this session, the user must reply: force continue
```

5. **User override**
   - User says **force continue** -> continue; repeat this checkpoint after the next step
   - Any other reply -> end the skill; recommend a new session
   - If **≥ 80%**: do not accept force continue - stop definitively

## Optional hooks

Context-only hooks under `~/.cursor/hooks/` (see `docs/HOOKS.md`):

- `beforeSubmitPrompt` - track `use skill sdd-spec|sdd-plan|sdd-develop|speckit-*|...` (always allows submit)
- `afterFileEdit` - record `PLAN/PLAN_*.md` or `.specify/**/tasks.md` edits
- `preCompact` - user message at 40%/80% usage before compaction

Hooks do **not** select models and do **not** read Claude Code session JSONL files.

## What not to do

- Do not rely on external `check-context.ps1` or `~/.claude/projects/*.jsonl` paths
- Do not continue multi-step SDD silently past 40% without saving and notifying
- Do not use absolute step counts as the only limit - prefer usage percentage when available

## Install path

After `scripts/sync-cursor.ps1`: `~/.cursor/rules/context-management.mdc` (see `docs/INSTALL.md`)
