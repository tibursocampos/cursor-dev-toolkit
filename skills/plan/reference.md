# PLAN template (plan skill)

Use this template when writing the PLAN at the resolved path (repository or global). **Default:** section titles and body in **Brazilian Portuguese (pt-BR)**. English only on explicit skill invocation override — see `sdd-artifact-language-pt-br.mdc`.

**File paths** and **test names** in English. No implementation code blocks in the PLAN.

Storage rules: `~/.cursor/skills/_shared/sdd-artifacts/STORAGE.md`.

## Filename and numbering

| Part | Rule |
|------|------|
| Folder | From manifest: `PLAN/` at repo root or `~/.cursor/sdd/<repo-id>/PLAN/` |
| Sequence | Same `NNN` (3 digits) as the source PRD |
| Slug | Short ASCII summary (kebab-case or snake_case; Portuguese allowed) |
| Example (repo) | `PLAN/PLAN_002_exportacao_perfil_usuario.md` |
| Example (global) | `~/.cursor/sdd/acme-payments-api/PLAN/PLAN_002_exportacao_perfil_usuario.md` |
| PRD link | Full path to PRD on disk (repo or global) |

## Storage and `.gitignore` (plan skill)

If PRD is global, PLAN is global unless the user chooses repository storage. Before `Write` in **repository** mode, follow `STORAGE.md`. Update manifest (`artifact_language`, folders).

## Product documentation language

If a step updates **project** `docs/` or README, the **plan** or **implement** skill must **ask** pt-BR vs English before writing that deliverable.

---

## Document template (pt-BR — default)

Copy from the heading below through **Checklist final**, then remove bracketed instructions.

```markdown
# PLAN: [Nome da feature]

| Campo | Valor |
|-------|--------|
| **PRD** | [caminho completo do PRD] |
| **Repositório** | [nome do PRD / raiz git] |
| **Stack** | [.NET / Angular / outro] |
| **Complexidade** | Baixa / Média / Alta |
| **Total de passos** | N (MVP) + M opcionais |
| **Progresso** | 0/N |

```
[⚪⚪⚪⚪⚪⚪⚪⚪] 0% (0/N)
```

## Objetivos

- [ ] O1: [Resultado mensurável ligado ao PRD]
- [ ] O2: [Resultado mensurável]
- [ ] O3: [Opcional]

## Árvore alvo (entregáveis)

[Listar arquivos ou módulos principais — só caminhos, sem código.]

```
[repo-root]/
├── [caminhos da exploração]
└── [tests]
```

## Estratégia de validação

- [ ] [Como a feature será verificada — unitário, integração, manual]
- [ ] .NET: xUnit, Moq, FluentAssertions; `Should_<Result>_When_<Condition>`
- [ ] Build passa local / CI

---

## Passos de implementação

### ⏳ PASSO 1: [Título curto]

**Status:** Pendente | **Concluído:** - | **Deps:** nenhuma | **Orçamento de tokens:** ~[k] | **Tempo:** [min]

**Entregáveis:**

- [ ] [Artefato concreto 1]
- [ ] [Artefato concreto 2]

**Arquivos:**

- `path/to/File.cs` (novo ou alterar)

**Tarefas:**

1. [Ação]
2. [Ação]

**Testes:**

- [ ] `Should_<Result>_When_<Condition>`
- [ ] [Cenário adicional]

**Aceite:**

- [ ] [Critério do CA do PRD]
- [ ] Build e testes direcionados passam

**Notas:** [Riscos; aviso se passo denso com 4+ arquivos]

---

### ⏳ PASSO 2: [Título curto]

**Status:** Pendente | **Concluído:** - | **Deps:** 1 | **Orçamento de tokens:** ~[k] | **Tempo:** [min]

[Repetir estrutura do bloco PASSO para cada baby step.]

---

## Ordem de execução

**Caminho crítico:** 1 → 2 → … → N

**Próximo passo:** PASSO 1 — [título]

---

## Mapa de componentes

| Camada / área | Caminhos |
|---------------|----------|
| Domain | [paths] |
| Application | [paths] |
| Infrastructure | [paths] |
| API / UI | [paths] |
| Tests | [paths] |

## Estratégia de testes

### Unitários

- [ ] [Cenário]

### Integração

- [ ] [Cenário]

### Manual (se necessário)

- [ ] [Cenário]

## Decisões técnicas

| Tópico | Decisão | Justificativa |
|--------|---------|---------------|
| [ex.: nome da propriedade] | [escolha] | [por quê] |

## Riscos e mitigações

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| [Risco 1] | Baixo/Médio/Alto | [Ação] |

## Referências

- PRD: [caminho completo]
- Docs do projeto: `docs/...`
- Diretrizes (lazy-load; não colar corpos):
  - `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md`
  - `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md`

## Protocolo de atualização do PLAN (skill implement)

Após cada passo concluído, a skill **implement** atualiza este arquivo:

1. Status do passo → **Concluído** com data
2. Barra de progresso e campo **Progresso**
3. Checkboxes de objetivos quando atendidos
4. Linha **Próximo passo** aponta para o PASSO seguinte

Não editar progresso manualmente durante implementação, exceto recuperação de sessão falha.

## Checklist final

- [ ] Todos os critérios de aceite do PRD mapeados em passos
- [ ] Cada passo cabe em uma sessão implement
- [ ] Dependências explícitas; sem ciclos
- [ ] Cenários de teste cobrem CA e bordas
- [ ] Sem código de implementação embutido no PLAN
- [ ] Handoff: `use skill implement — <caminho-completo-do-plan> — Step 1`
```

---

## Status legend

| Marcador | Significado |
|----------|-------------|
| ⏳ PASSO N | Pendente |
| 🔄 PASSO N | Em progresso (sessão implement ativa) |
| ✅ PASSO N | Concluído |
| ❌ PASSO N | Bloqueado |

Use **Pendente** / **Concluído** / **Bloqueado** na linha `**Status:**`; emoji no título é opcional.

**Implement skill:** step headings may use `STEP` or `PASSO`; match the PLAN file when updating.

---

## Baby-step sizing checklist

- [ ] Nenhum passo com 4+ arquivos novos sem dividir
- [ ] Migração e mapeamento EF separados quando ambos aplicam
- [ ] Handler, consumer e testes não no mesmo passo salvo trivial
- [ ] Passos densos com aviso de contexto para implement
- [ ] Passo opcional de docs só se contrato ou comportamento visível mudar — **perguntar idioma da doc do sistema**

---

## Quality checklist (before handoff)

- [ ] Caminho do PRD e sequência batem com o nome do PLAN
- [ ] Todo critério de aceite do PRD aparece em algum passo
- [ ] Passos em pt-BR (salvo override inglês)
- [ ] Sem blocos de implementação completa
- [ ] Caminho de saída: `PLAN/PLAN_NNN_*.md` ou global (não `PLANO_*` na raiz do repo)
- [ ] Handoff com `use skill implement`
- [ ] Progresso inicial `0/N`
