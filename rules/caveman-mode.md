---
description: Automatically apply response compression rules (Caveman Mode) if enabled in preferences
alwaysApply: true
---

# Caveman Mode (Response Compression)

## Rules and Control

You must check and manage the Caveman Mode status on behalf of the user.

### 1. In-Session Toggle Commands
Watch the user chat for these exact commands:
- **`caveman on`**:
  1. Write/update `$HOME/.cursor/sdd/preferences.json` to set `{"caveman_mode": true}` (create parent directories and file if missing).
  2. Confirm in chat: `"🪨 Modo Caveman ativado."`
  3. Apply the compression rules below immediately.
- **`caveman off`**:
  1. Write/update `$HOME/.cursor/sdd/preferences.json` to set `{"caveman_mode": false}`.
  2. Confirm in chat: `"🪨 Modo Caveman desativado."`
  3. Resume normal communication style immediately.

### 2. Preference Check
At the beginning of each session or task (Step -1):
1. Read the preferences file: `$HOME/.cursor/sdd/preferences.json`.
2. If it does not exist: create it with `{"caveman_mode": false}`.
3. If `caveman_mode` is `true`:
   - Load the full guidelines from `~/.cursor/skills/_shared/caveman/CAVEMAN.md`.
   - Display this activation message in chat (pt-BR):
     > 🪨 Modo Caveman ativo (respostas compactas). Digite `caveman off` a qualquer momento para desativar.
   - Enforce compression rules corresponding to the active skill (Lite or Full).

### 3. Compression Rules (When Enabled)

- **Universal Protections (NEVER compress)**:
  - Fenced code blocks (any language).
  - File paths and directories.
  - Error messages and stack traces.
  - CLI command suggestions.
  - Confirmation gates like `(sim / ajustar / cancelar)`.
  - Artifact drafts (specs, plans, tasks, commits).

- **Lite Mode (Apply to `sdd-spec`, `sdd-plan`, `speckit-spec`, `speckit-plan`)**:
  - Strip preambles, greetings, and post-draft pleasantries.
  - Keep clarifying questions, draft previews, and section headers intact.

- **Full Mode (Apply to other tasks, e.g. `sdd-develop`, `code-review`, `developer`, `fix-build`, `test-coverage`)**:
  - Communicate telepathically. Eliminate all polite filler, narration, and intros.
  - Use bullet points, short action phrases, and single-line status confirmations (e.g., `"✅ Tarefa concluída."`).
