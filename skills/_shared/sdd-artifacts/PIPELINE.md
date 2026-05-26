# SDD pipeline guards (spec / plan / implement)

Execution order, Cursor mode behavior, canonical paths, confirmation gates, and missing-artifact dialogs. Load at **step -1** of `spec`, `plan`, and `implement` — do not paste into PRD/PLAN bodies.

Install path after sync: `~/.cursor/skills/_shared/sdd-artifacts/PIPELINE.md`

Companion: `STORAGE.md` (folders, manifest, `.gitignore`).

## Skill order

Fixed sequence: **`spec` → `plan` → `implement`**. Never skip a stage unless the user explicitly chooses a documented shortcut (see § Missing artifacts).

| Skill | Writes | Must not in same session |
|-------|--------|---------------------------|
| `spec` | PRD + manifest | PLAN; production/test code (`*.cs`, migrations, etc.) |
| `plan` | PLAN + manifest | PRD body; production/test code |
| `implement` | Code (English) + PLAN progress | New PRD/PLAN files |

## Canonical paths

### Valid PRD

- `PRD/NNN_*.md` or `docs/PRD/NNN_*.md` (workspace)
- `~/.cursor/sdd/<repo-id>/PRD/NNN_*.md` (global)

`NNN` = three digits. Slug after underscore.

### Valid PLAN

- `PLAN/PLAN_NNN_*.md` (workspace)
- `~/.cursor/sdd/<repo-id>/PLAN/PLAN_NNN_*.md` (global)

PLAN `NNN` **must match** source PRD `NNN`.

### Forbidden final destinations

Do **not** treat these as SDD PRD/PLAN:

- `~/.cursor/` outside `sdd/<repo-id>/PRD/` or `.../PLAN/`
- `docs/backlog/*.md`, arbitrary `docs/*.md`, repo-root `*.md` without `NNN_` / `PLAN_NNN_`
- User-pasted paths that fail the patterns above

### Promote non-canonical `.md`

1. `Read` the file the user cited.
2. Build PRD (or PLAN) content per `spec/reference.md` or `plan/reference.md`.
3. Run § Confirm before write.
4. `Write` only to a canonical path.
5. Do not delete the old file unless the user asks.

Manifest `prd_folder` / `plan_folder` must resolve to one of the canonical layouts in `STORAGE.md`.

## Cursor mode — Phase A / Phase B

**Product limit:** In **Plan** and **Ask** modes, `Write`/`Edit` and often shell are blocked. User “permission” in chat does **not** enable disk writes.

| Phase | Modes | Actions |
|-------|-------|---------|
| **A — Collect & draft** | Plan, Ask, Agent | Questions, `Read`/Glob/Grep, PRD/PLAN draft in chat, content approval |
| **B — Persist** | **Agent** only | `Write` PRD/PLAN after § Confirm; `implement` code; `test-coverage` runs |

| Mode | `spec` / `plan` | `implement` | `test-coverage` |
|------|-----------------|-------------|-----------------|
| Agent | Write after confirm | Allowed | Allowed |
| Plan | Phase A only; no `Write`; never claim “saved” | Draft/analysis only; no `Edit` on code | Explain tests need Agent |
| Ask | Same as Plan | Block code changes | Block test execution |

### Phase A complete — prompt user (pt-BR)

Copy when content is approved but disk write or tests are still pending:

```text
Rascunho aprovado. Para gravar o arquivo em `{path}` (ou executar testes),
altere para o modo **Agent** e envie:

use skill <nome> — gravar

(Opcional: cole o caminho do PRD/PLAN se já tiver sido definido.)
```

If the user insists on staying in Plan: continue Phase A only; **never** state “PRD/PLAN salvo em …” without a successful `Write`.

## Confirm before write (spec and plan)

Always before the first `Write` of a **new** PRD or PLAN (and when replacing an empty draft file):

1. Show: title, `NNN`, **full resolved path**, storage mode, 3–5 content bullets, planned status.
2. Ask (pt-BR): **“Posso gravar em `{path}`? (sim / ajustar / cancelar)”**
3. `Write` only after explicit **sim**.
4. **ajustar** → revise draft in chat, ask again. **cancelar** → do not write.

`implement` updates the existing PLAN file after completing a step without re-asking storage (per `context-management.mdc`).

## Prior context (chat, Plan, code-review)

When the thread already has requirements, review findings, or refined backlog:

- Do **not** run the full `spec` questionnaire.
- Provide a structured summary + **at most 3** gap questions.
- Map code-review items to PRD sections (acceptance criteria, risks, out of scope) per `spec/reference.md`.

## Missing canonical artifact — ask before handoff

Use **one** structured question (pt-BR). Do not invent PRD/PLAN or write code in this step.

### `plan` without PRD on disk

```text
Não encontrei um PRD em PRD/NNN_*.md (nem em ~/.cursor/sdd/<repo-id>/PRD/).

Como prefere continuar?

1) Criar o PRD primeiro (recomendado para SDD completo)
2) Montar o PLAN direto — você envia as especificações na próxima mensagem
```

| Choice | Next step |
|--------|-----------|
| **1** | Ask: *“Envie as orientações do PRD (texto) ou o caminho de um arquivo .md para analisar.”* → run **`spec`** (Phase A; persist in Agent). Handoff when PRD exists: `use skill plan — <full-prd-path>` |
| **2** | Ask: *“Envie as especificações (texto) ou o caminho de um arquivo para análise.”* → analyze → PLAN draft in chat; note ideal SDD has a PRD; persist PLAN only with canonical path + § Confirm. Suggest option **1** if scope is large |

Explicit “criar PRD” while invoking `plan` → treat as choice **1**; do not write PLAN until a canonical PRD exists unless user chose **2**.

### `implement` without PLAN on disk

```text
Não encontrei um PLAN em PLAN/PLAN_NNN_*.md (nem global).

1) Criar PRD + PLAN antes (spec → plan)
2) Só criar o PLAN — você envia PRD ou especificações na próxima mensagem
3) Você já tem um arquivo de plano — informe o caminho (será validado/promovido se necessário)
```

| Choice | Action |
|--------|--------|
| **1** | Guide to `spec` (use § plan without PRD, choice **1**) then `plan` |
| **2** | If canonical PRD exists → `plan`; else ask for specs or file (same as plan choice **2** inputs) |
| **3** | `Read` path; if invalid → promote per § Promote |

### Path validation helper

Before `Write`, confirm the target matches:

- PRD: `(PRD|docs/PRD)/\d{3}_.+\.md` (workspace-relative) or `.../sdd/<repo-id>/PRD/\d{3}_.+\.md`
- PLAN: `PLAN/PLAN_\d{3}_.+\.md` or global equivalent

If validation fails, do not write — fix path or promote.

## Integration

| Consumer | Use |
|----------|-----|
| `spec`, `plan`, `implement` | Step -1 load; steps reference § by name |
| `STORAGE.md` | Folders, manifest, invalid-path summary |
| `rules/sdd-pipeline-guards.mdc` | Short always-on reminder |
| `code-review` | Handoff to `spec` for new PRD; read-only SDD discovery |
| `test-coverage` | Phase B / Agent for shell; report paths in `reference.md` |
