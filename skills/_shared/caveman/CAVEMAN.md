# Caveman Mode - Response Compression Guideline

Single source of truth for Caveman Mode behavior across all participating skills.
Load on demand from skills at step -1 - do not pre-load.

Install path after sync: `~/.cursor/skills/_shared/caveman/CAVEMAN.md`

---

## What Caveman Mode Does

Forces the agent to respond in telegraphic, concise fragments - eliminating
conversational filler, preambles, and polite wrapper text - while preserving
100% of technical content (code, paths, artifact drafts, confirmation gates).

Inspired by: https://github.com/juliusbrussee/caveman  
Expected savings: 22-87% of output prose tokens per session.

---

## Preferences File

**Location:** `$env:USERPROFILE\.cursor\sdd\preferences.json`

**Structure:**
```json
{
  "caveman_mode": false
}
```

**Resolution algorithm (run at step -1 of participating skills):**

```
1. Check if preferences.json exists at the location above.
   - If NOT exists: create it with { "caveman_mode": false }. Mode = OFF.
2. Read value of "caveman_mode".
   - If true:  Mode = ON  -> load this file, display activation notice.
   - If false: Mode = OFF -> skip rest of this file.
3. During session: watch for user typing "caveman off" or "caveman on".
   - "caveman off" -> set caveman_mode: false in preferences.json. Confirm in chat (pt-BR): "🪨 Modo Caveman desativado."
   - "caveman on"  -> set caveman_mode: true  in preferences.json. Confirm in chat (pt-BR): "🪨 Modo Caveman ativado."
```

**Activation notice (display in chat when mode is ON):**
> 🪨 Modo Caveman ativo (respostas compactas). Digite `caveman off` a qualquer momento para desativar.

---

## Participation Levels

| Skill | Level |
|---|---|
| `commit` | **NEVER** - excluded regardless of setting |
| `sdd-spec`, `sdd-plan` | **LITE** when mode ON |
| `code-review`, `developer`, `fix-build`, `test-coverage` | **FULL** when mode ON |
| `sdd-develop` | **FULL** when mode ON |

**Always protected in every skill (never compressed under any mode):**
- Confirmation gates: `(sim / ajustar / cancelar)` blocks
- Artifact drafts shown in chat: `spec.md`, `plan.md`, `tasks.md`, PRD, PLAN, commit suggestions
- Technical identifiers: file paths, function/type names, CLI commands, error messages
- Security guardrails and Git blocking notices

---

## Full Mode Rules

Apply to: `code-review`, `developer`, `fix-build`, `test-coverage`, `sdd-develop`.

**Strip completely:**
- Opening preambles ("Claro! Vou ajudar com isso.", "Ótima pergunta!", "Com certeza!")
- Closing pleasantries ("Espero ter ajudado!", "Qualquer dúvida é só perguntar!")
- Redundant framing ("Como solicitado, vou agora...", "Conforme discutimos...")
- Verbose progress narration ("Primeiro vou analisar o arquivo X, depois vou verificar Y...")

**Replace with:**
- Direct action statements ("Analisando X...", "Erro em Y:", "Alteração:")
- Bullet-first format for lists without lead-in sentences
- Single-line status confirmations ("✅ Tarefa concluída.", "⚠️ Falha detectada:")

**Always preserve intact:**
- Code blocks (any language)
- File paths and directory trees
- Error messages and stack traces
- Command suggestions
- Confirmation gates and security guardrail text
- Artifact drafts (spec/sdd-plan/tasks/commit content)

---

## Lite Mode Rules

Apply to: `sdd-spec`, `sdd-plan`.

**Strip:**
- Opening preambles and framing before questions
- Closing wrap-up phrases after presenting drafts
- Redundant context restatements ("Como você mencionou antes...", "Baseado no que discutimos...")

**Preserve intact (in addition to universal protections):**
- Clarifying questions (content must remain clear and complete)
- Artifact draft previews shown for user review
- Confirmation gates `(sim / ajustar / cancelar)`
- All section headers and structured content within drafts

---

## Phrase Reference

### Blocked (Full Mode)
| Instead of | Use |
|---|---|
| "Claro! Vou ajudar com isso. Aqui está o que farei:" | *(nothing - go straight to action)* |
| "Analisando o arquivo solicitado, identifiquei que..." | "Identificado:" |
| "Após concluir esta etapa, o próximo passo será..." | "Próximo: Task N+1" |
| "Espero que isso resolva o problema!" | *(omit)* |
| "Com prazer! Antes de prosseguir, preciso verificar..." | "Verificando:" |

### Always Preserved (any mode)
```
Posso gravar em `{path}`? (sim / ajustar / cancelar)
```
```
⚠️ Nenhum comando mutante do Git será executado sem autorização explícita.
```
```
✅ Task N marcada como concluída em `{path}`.
```

---

## Integration

| Consumer | Load condition |
|---|---|
| `sdd-develop` | Step -1, if caveman_mode check passes |
| `code-review`, `developer`, `fix-build`, `test-coverage` | Step -1, if caveman_mode check passes |
| `sdd-spec`, `sdd-plan` | Step -1, if caveman_mode check passes (Lite rules only) |
| `AGENTS.md` | Reference only - documents the toggle and participation table |
| `PIPELINE.md` | Reference only - documents confirmation gate protection |
