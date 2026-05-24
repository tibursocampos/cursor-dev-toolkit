# Cursor hooks (optional)

Context and PLAN checkpoint helpers. Installed under `~/.cursor/` by `scripts/sync-cursor.ps1`. Full install flow: [INSTALL.md](INSTALL.md).

## What hooks do

| Hook | Script | Purpose |
|------|--------|---------|
| `beforeSubmitPrompt` | `hooks/context-before-prompt.ps1` | Detect `use skill spec|plan|implement|...` and record session state |
| `afterFileEdit` | `hooks/plan-after-edit.ps1` | Record edits to `PLAN/PLAN_*.md` for compaction reminders |
| `preCompact` | `hooks/context-pre-compact.ps1` | Show user message before context compaction (40%/80% thresholds) |

## What hooks do not do

- **No model selection** — hooks never pick or switch LLM models (PRD FR6).
- **No external session JSONL** — hooks do not read `~/.claude/projects/*.jsonl` or similar paths.
- **No token metering on every prompt** — `beforeSubmitPrompt` cannot inject `additional_context` in current Cursor API; rely on `context-management.mdc` and visible usage when available.

## Install

From the toolkit repo root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1
```

This copies hook scripts to `~/.cursor/hooks/` and **merges** `hooks/hooks.json` into `~/.cursor/hooks.json` (additive by `command`; existing user hook entries are kept).

Manual install (same result):

1. Copy `hooks/*.ps1` to `%USERPROFILE%\.cursor\hooks\` (or `~/.cursor/hooks/`).
2. Merge `hooks/hooks.json` into `%USERPROFILE%\.cursor\hooks.json` (do not overwrite unrelated entries).
3. Restart Cursor or save `hooks.json` so hooks reload.

Paths in `hooks.json` are relative to `~/.cursor/` when installed globally.

## State files

Written under `~/.cursor/hooks-state/`:

| File | Content |
|------|---------|
| `sdd-session.json` | Last SDD skill seen in a user prompt |
| `plan-edit.json` | Last PLAN file path and UTC timestamp |

## Windows PowerShell

- Requires **Windows PowerShell 5.1+** or PowerShell 7 (`pwsh`).
- Commands use `-NoProfile -ExecutionPolicy Bypass` so hooks run in the Cursor hook process.
- Scripts use ASCII status tags (`[WARNING]`, `[CRITICAL]`) to avoid encoding issues on PS 5.1.

## Smoke test (repo root)

```powershell
cd path\to\cursor-dev-toolkit

'{"prompt":"use skill implement - PLAN/PLAN_001.md - Step 1","attachments":[]}' |
  powershell -NoProfile -File hooks\context-before-prompt.ps1

'{"file_path":"D:/proj/PLAN/PLAN_001_feature.md","edits":[]}' |
  powershell -NoProfile -File hooks\plan-after-edit.ps1

'{"trigger":"auto","context_usage_percent":85,"context_tokens":120000,"context_window_size":200000,"message_count":10,"messages_to_compact":5,"is_first_compaction":false}' |
  powershell -NoProfile -File hooks\context-pre-compact.ps1
```

Expected: first script prints `{"continue":true}`; third prints JSON with `user_message`.

## Limits

- `afterFileEdit` has no output fields — only sidecar state for `preCompact`.
- `beforeSubmitPrompt` `user_message` is shown when submission is **blocked**; this toolkit always returns `continue: true`.
- Compaction reminders depend on Cursor passing `context_usage_percent` into `preCompact` (may be absent in some builds).
- Project-level hooks (`.cursor/hooks.json` in a consumer repo) are optional; this package targets user-level `~/.cursor/`.

## Related rules

- `rules/context-management.md` → `~/.cursor/rules/context-management.mdc`
- `rules/user-language-pt-br.md` → reply language (not handled by hooks)
