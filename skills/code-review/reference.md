# Code review — report template and checklists

Use when writing the final report for the `code-review` skill. Keep the report in **Brazilian Portuguese (pt-BR)** (technical terms may stay in English). Replace bracketed placeholders.

---

## SDD artifact resolution

Run in **step 0.5** before scoping the diff. Load `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md`. On Windows, `~/.cursor/sdd/` is `%USERPROFILE%\.cursor\sdd\`.

### Checklist

1. **Target repo** — open workspace is the project under review (not `cursor-dev-toolkit` unless that is the subject).
2. **`<repo-id>`** — per `STORAGE.md`: `git remote get-url origin` → slug; else workspace root basename; reuse `repo_id` from manifest when present.
3. **Manifest** — read `~/.cursor/sdd/<repo-id>/manifest.json` when it exists and `workspace_root` (normalized separators, case-insensitive on Windows) matches the open workspace → use `prd_folder` and `plan_folder` (may be absolute paths, e.g. `C:/Users/.../PRD`).
4. **Glob** (parallel):

   | Location | Patterns |
   |----------|----------|
   | Workspace | `PRD/*.md`, `docs/PRD/*.md`, `PLAN/PLAN_*.md` |
   | Global | `~/.cursor/sdd/<repo-id>/PRD/*.md`, `~/.cursor/sdd/<repo-id>/PLAN/PLAN_*.md` |

5. **Extract `NNN`** — first three digits from PRD filename (`001_...md`) and from PLAN (`PLAN_001_...md`).
6. **Pair** — match PRD and PLAN with the same `NNN`.
7. **Select one pair** (first match wins):

   | Priority | Signal |
   |----------|--------|
   | 1 | User passed explicit PRD or PLAN path in invocation |
   | 2 | PLAN header field **PRD** points to a discovered PRD path |
   | 3 | `NNN` or feature slug aligns with current branch name |
   | 4 | Single pair after pairing |
   | 5 | Ask once in pt-BR — numbered list of PRD + PLAN paths |

8. **Read** selected PRD and PLAN before SDD traceability (step 2).
9. **Report** — always record full paths used (workspace-relative or absolute global).

### Outcomes

| Result | Action |
|--------|--------|
| One pair found | Proceed with SDD traceability |
| No artifacts after full search | Report **Limitação SDD** (technical/guidelines review only); do not state PRD/PLAN "do not exist" |
| Multiple ambiguous pairs | Ask user once; then proceed |

---

## Report template

```markdown
# Code review — [Nome da feature]

## Resumo executivo

**Decisão:** Aprovado | Aprovado com ressalvas | Alterações necessárias

| Métrica | Valor |
|---------|-------|
| Aderência ao PRD | [ex.: 4/4 critérios] |
| Status do PLAN | [ex.: 6/6 passos concluídos] |
| SDD | [PRD/PLAN encontrados — caminhos] ou **Limitação SDD** (busca completa sem artefatos) |
| Arquivos revisados | [N] |
| Build / testes | [Passou / Falhou / Não executado] |
| Críticos | [0] |
| Importantes | [N] |
| Nice-to-have | [N] |

[Um parágrafo: escopo, principais achados, recomendação.]

---

## Verificação do PLAN (SDD)

_Omitir esta seção somente se step 0.5 registrou **Limitação SDD**._

**PLAN:** [caminho completo]

- Progresso: [X/N] — [consistente | inconsistências listadas]
- Passos concluídos: [lista]
- Pendente / desvio: [lista ou Nenhum]

---

## Aderência ao PRD (SDD)

_Omitir esta seção somente se step 0.5 registrou **Limitação SDD**._

**PRD:** [caminho completo]

### Critérios de aceite

| Critério | Status | Evidência |
|----------|--------|-----------|
| [CA1] | Atendido / Parcial / Ausente | [arquivo, teste] |

### Regras de negócio

| Regra | Status | Local |
|-------|--------|-------|
| [RN01] | Atendida / Ausente | [tipo.método] |

---

## Arquivos revisados

- [caminho] — [nota breve]

---

## Pontos positivos

- [Boas práticas observadas]

---

## Problemas críticos (bloqueantes)

### [Título]

- **Arquivo:** `caminho:linha`
- **Categoria:** Segurança | Bug | Breaking change
- **Problema:** [o que está errado]
- **Impacto:** [por que bloqueia merge]
- **Correção sugerida:** [passos concretos]

---

## Problemas importantes (não bloqueantes)

### [Título]

- **Arquivo:** `caminho:linha`
- **Problema:** [o que melhorar]
- **Sugestão:** [como]

---

## Nice-to-have

- [Melhorias opcionais]

---

## Testes

- **Unitários:** [passou/falhou, escopo]
- **Integração:** [passou/falhou, escopo]
- **Lacunas:** [cenários não cobertos]

---

## Segurança

- [ ] Sem secrets hardcoded
- [ ] Validação de entrada em dados externos
- [ ] Sem dados sensíveis em logs
- [ ] Acesso a dados parametrizado (sem concatenação SQL)

Problemas: [Nenhum | listados]

---

## Performance

- [ ] Sem N+1 óbvio no código alterado
- [ ] Async em trabalho I/O-bound
- [ ] Sem loops/alocações ilimitados em hot paths

Problemas: [Nenhum | listados]

---

## Oportunidades de refatoração (opcional)

| Prioridade | Área | Benefício |
|------------|------|-----------|
| Média | [método/classe] | [legibilidade / testabilidade] |

---

## Recomendação final

**Decisão:** [Aprovado | Aprovado com ressalvas | Alterações necessárias]

**Obrigatório antes do merge:**

1. [Ação ou Nenhuma]

**Recomendado após o merge:**

1. [Ação ou Nenhuma]

**Próximos passos do autor:**

- [ ]
```

---

## .NET review checklist (condensed)

**Structure**

- [ ] Clean Architecture layers respected
- [ ] Namespaces and folder layout consistent
- [ ] Single responsibility; focused methods

**C#**

- [ ] Explicit types; nullable reference types where enabled
- [ ] Async/await for I/O; `CancellationToken` propagated
- [ ] No unjustified `dynamic` or blocking `.Result` / `.Wait()`
- [ ] Resources disposed (`using`, `IAsyncDisposable`)

**Tests**

- [ ] xUnit + Moq + FluentAssertions
- [ ] Names: `Should_<Result>_When_<Condition>`
- [ ] Arrange / Act / Assert structure
- [ ] Edge cases and failure paths where behavior changed

**EF / data**

- [ ] No obvious N+1; `AsNoTracking` for read-only queries when appropriate
- [ ] Migrations safe (up/down, indexes, no unintended data loss)

---

## Angular / frontend checklist (when applicable)

- [ ] No unjustified `any`; typed inputs and API models
- [ ] HTTP errors handled; services return typed results
- [ ] Build: `npm run build` (or project script)
- [ ] Tests: `npm test` when present

---

## Code smell quick scan

| Smell | Look for |
|-------|----------|
| Long method | > ~30 lines in changed code |
| Large class | Multiple unrelated responsibilities |
| Duplication | Same logic in 2+ places |
| Feature envy | Method mostly uses another type’s data |
| Primitive obsession | Many primitives where a value object fits |

---

## Approval criteria

**Approved:** PRD/PLAN satisfied; no critical issues; build/tests pass or user accepts documented gaps.

**Approved with reservations:** Minor issues or PLAN cosmetic drift; no security or correctness blockers.

**Changes required:** Security vulnerability; broken behavior; missing PRD scope; build/test failure; critical architecture violation.
