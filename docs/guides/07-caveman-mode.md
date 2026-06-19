# Caveman Response Compression Guide

This guide details the **Caveman Response Compression Mode**, an optional feature designed to reduce output token consumption by stripping away polite filler text and verbose progress narration, while fully protecting technical facts, code blocks, and confirmation gates.

---

## 1. What is Caveman Mode?

Caveman Mode directs the agent to communicate in telegraphic, extremely concise fragments rather than complete polite paragraphs. 

* **Goal**: Reduce token usage (expected savings of **22–87%** of conversational prose tokens).
* **Rule**: Go straight to the technical facts and actions.
* **Exceptions**: Never compress code blocks, file paths, security/git warnings, or confirmation options.

---

## 2. Configuration & State

Caveman Mode's state is persisted globally on the user's machine:

* **File Location**: `~/.cursor/sdd/preferences.json`
* **JSON Structure**:
  ```json
  {
    "caveman_mode": false
  }
  ```

### Lifecycle & Resolution Algorithm (Step -1)
Every participating skill executes a validation and load check at **Step -1**:
1. **Detection**: Check if `preferences.json` exists.
2. **Auto-creation**: If the file is missing, create it with `"caveman_mode": false` (disabled by default).
3. **Execution**: If `"caveman_mode": true`, the skill loads `_shared/caveman/CAVEMAN.md` rules and displays this activation notice in the chat:
   > 🪨 Modo Caveman ativo (respostas compactas). Digite `caveman off` a qualquer momento para desativar.

### In-Session Control Commands
The user can toggle the state at any point in the chat session:
* **`caveman on`**: Modifies the preferences file to set `caveman_mode: true` and confirms in chat: `"🪨 Modo Caveman ativado."`
* **`caveman off`**: Modifies the preferences file to set `caveman_mode: false` and confirms in chat: `"🪨 Modo Caveman desativado."`

---

## 3. Participation Levels

Different skills implement compression to varying degrees to preserve clarity where it matters most:

| Participation Level | Skills | Behavior |
|---|---|---|
| **NEVER** | `commit` | Standard communication. Excluded to ensure critical git operations and commit messages remain completely natural. |
| **LITE** | `spec`, `plan`, `speckit-spec`, `speckit-plan` | Compresses preambles and greeting text, but preserves clarifying questions and artifact drafts (like `spec.md`/`plan.md` previews) 100% intact. |
| **FULL** | `code-review`, `dotnet-developer`, `fix-build`, `test-coverage`, `implement`, `speckit-develop` | Compresses all prose. Strips introductory and concluding pleasantries entirely. Uses direct bullet points and action statements instead of sentences. |

---

## 4. Universal Protections

Under **no circumstances** (even in **FULL** mode) are the following elements compressed, modified, or omitted:
1. **Confirmation Gates**: Prompt messages requiring user feedback, such as `(sim / ajustar / cancelar)`.
2. **Technical Artifacts**: Fenced code blocks, file paths, type/function identifiers, CLI command suggestions, and stack traces.
3. **Safety Guardrails**: Security warnings, structural limit warnings, and git-blocker alerts.

---

## 5. Phrase Reference Examples

### Full Mode Prose Style

| Instead of (Verbose) | Use (Telegraphic) |
|---|---|
| *"Sure, I can help you with that! Here is the plan of action I'm going to take:"* | *(Omit entirely — go straight to action or checklist)* |
| *"After analyzing the requested files, I noticed that..."* | *"Identified:"* |
| *"Once this task is completed, we will proceed to the next step, which is..."* | *"Next: Task N+1"* |
| *"I hope this resolves your compilation error! Let me know if you need anything else."* | *(Omit entirely)* |
