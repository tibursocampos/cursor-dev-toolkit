# Forma C: orquestração multi-agente (O1 / O2 / O3)

**Índice:** [Guides README](README.md) · **PRD:** `PRD/003_orquestracao_multiagente.md` · **PLAN:** `PLAN/PLAN_003_orquestracao_multiagente.md`

**Idioma deste guide:** pt-BR (guide de agente). Skills e identificadores permanecem em inglês.

---

## O que é

A **Forma C** é o fluxo orquestrado do toolkit para trabalho **complexo / multi-história / brownfield**:

0. **Step 0 Memory Bank Gate** - antes de O1/O2/O3: garante `memory-bank/` saudável no **repo alvo** (política `auto` por padrão). Ver seção [Step 0](#step-0--memory-bank-gate).
1. **O1 `orchestrate-analyze`** - triage, especialistas condicionais (Task), backlog US/TS sob `features/NNN-slug/`, gate humano.
2. **O2 `orchestrate-deliver`** - PRD + PLAN por história (reusa contratos `sdd-spec` / `sdd-plan`), série ou paralelo, handoff com paths.
3. **O3 `orchestrate-develop`** *(opcional)* - um subagente por passo do PLAN (contrato `sdd-develop`). Alternativa: `sdd-develop` manual.

Orquestradores **não escrevem código de aplicação**. O contrato de **1 step por sessão** de `sdd-develop` permanece intacto. Forma A (`sdd-*`) **não** exige memory-bank.

---

## Formas A / B / C (coexistem)

| Forma | Quando usar | Pipeline |
|-------|-------------|----------|
| **A** Classic | Uma feature clara, caminho único | `sdd-spec` -> `sdd-plan` -> `sdd-develop` |
| **B** Backlog | Item informal antes de SDD | `refine-backlog-item` -> `breakdown-tasks` -> A ou C |
| **C** Orquestrada | Várias histórias, brownfield, precisa de especialistas | O1 -> O2 -> O3 **ou** `sdd-develop` |

Nenhuma Forma deprecia a outra neste MVP (CA7 / RN02).

---

## Quando usar / quando não usar

### Use Forma C quando

- Escopo **multi-história** (várias US/TS) ou **brownfield** (ex.: extração NuGet).
- Precisa de **análise paralela** (repo, arquitetura, segurança) antes de spec.
- Quer um **handoff tipado** com paths de PLAN por história.

### Não use Forma C quando

- Fix pequeno / área única -> `developer` ou `*-developer` ([02](02-developer.md), [08](08-stack-developers.md)).
- Uma história clara sem orquestração -> Forma A ([01](01-sdd-workflow.md)).
- Só refinar um item de backlog -> Forma B ([05](05-operational-skills.md)).

---

## Pré-requisitos

1. Toolkit sincronizado: `.\scripts\sync-cursor.ps1` ([Install](../INSTALL.md)).
2. Repositório **alvo** aberto no Cursor (modo **Agent**).
3. Gates de sessão (`SESSION.md`): confirmações **sim** nos pontos high-cost.
4. Storage classic resolvido (`features/` no repo ou `~/.cursor/sdd/<repo-id>/features/`).

### Pós-sync (obrigatório após merge/pull do toolkit)

No clone do **cursor-dev-toolkit** (ou após atualizar skills O1/O2/O3):

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validation\validate-all.ps1
```

Esperado: `Smoke test PASSED` (skills no repo = **34**, incluindo `orchestrate-*` e `memory-bank-init`). Menu interativo: `.\scripts\toolkit.ps1`. Detalhes: [MAINTAINER_GUIDE](../MAINTAINER_GUIDE.md), [INSTALL](../INSTALL.md).

Sem sync, `/orchestrate-*` pode falhar (skills só existem em `~/.cursor/skills/` após o deploy).

---

## Step 0 - Memory Bank Gate

Antes de O1, O2 ou O3, o orquestrador executa o **Memory Bank Gate** (`MEMORY-BANK.md`):

| Situação | Comportamento (`auto`) |
|----------|-------------------------|
| `memory-bank/` ausente | Pede **sim** -> create (skill `/memory-bank-init` ou fluxo embutido) |
| Bank incompleto / stale | Pede **sim** -> refresh |
| Bank saudável | Continua **sem** write |

- Path: co-localizado com `features/` via manifest - `$Cwd/memory-bank/` (repository) ou `<classic.path>/memory-bank/` (global). Nunca sob `features/NNN-slug/`.
- Local only: em modo **repository**, `/memory-bank/` entra no bloco SDD do `.gitignore` (árvore inteira). Em modo **global**, **não** alterar o `.gitignore` do projeto.
- `CONTINUITY.md` guarda só referência: path + status (`fresh` \| `refreshed` \| `created`).
- Política `skip` só com flag explícita (ex.: `skip-memory-bank`). Silêncio ≠ skip.
- Init/refresh manual: `/memory-bank-init` (`refresh` / `refresh-light`). Inventário: `scripts/inventory/Invoke-MemoryBankInventory.ps1 -BankPath <bank_root>`.
- **Step N (O3):** após mudanças de código, `refresh-light` no fim do develop (confirmado).

**Fluxo:** Step 0 -> O1 -> O2 -> (O3 + Step N \| `sdd-develop`).

---

## Como invocar

| Fase | Invoke |
|------|--------|
| Memory bank (manual) | `/memory-bank-init` (`- refresh` / `- refresh-light`) |
| O1 Análise | `/orchestrate-analyze` |
| O1 retomar | `/orchestrate-analyze - <full-feature-path>` |
| O2 Spec/Plan | `/orchestrate-deliver - <full-feature-path>` |
| O3 Develop | `/orchestrate-develop - <full-feature-path>` |
| Develop manual | `/sdd-develop - <full-plan-path> - Step N` |
| Review | `/code-review` (passe `single` ou `multi-angle`; se omitir, a skill pergunta) |

`<full-feature-path>` - exemplo: `features/004-nuget-extract/`

---

## Passo a passo

### O1 - `orchestrate-analyze`

1. **Step 0:** Memory Bank Gate (`auto`) - create/refresh só após **sim**; bank saudável = só leitura.
2. Descreva a feature (ou cole notas / saída de Forma B).
3. O agente faz triage: nature, complexity, scope, flags `needs_*`.
4. Especialistas sobem via Task **só** se a flag for verdadeira (podem receber path do bank).
5. Grava `FEATURE.md`, `CONTINUITY.md` (campo Memory-bank), pastas `USnn`/`TSnn` com `STORY.md`.
6. **Pare** e aprove o backlog (**sim** / ajustar / cancelar).
7. Handoff: `/orchestrate-deliver - <full-feature-path>`

### O2 - `orchestrate-deliver`

1. **Step 0** de novo no início da sessão O2 (fresh -> sem reescrita).
2. Informe o path da feature aprovada.
3. Escolha modo **série** ou **paralelo**. Em paralelo: cada filho **só rascunha** PRD/PLAN; o pai agrega, pede **sim** e grava.
4. Cada história recebe `PRD/` + `PLAN/` (contratos sdd-spec / sdd-plan).
5. Aprove PRD/PLAN por história ou em lote.
6. Receba a tabela de paths + invokes para develop / O3.

### O3 - `orchestrate-develop` (ou manual)

1. **Step 0** no início da sessão O3; filhos recebem path do bank para leitura.
2. O3: pai atualiza CONTINUITY e dispara **um** subagente por passo pendente (deps respeitadas).
3. Manual: nova sessão por passo - `/sdd-develop - <plan> - Step N` (Forma A: gate memory-bank **opcional**).
4. Ao concluir a história: `/code-review` (single ou multi-ângulo; se omitir, a skill pergunta).

---

## Storage sob `features/`

```text
features/NNN-slug/
├── FEATURE.md
├── CONTINUITY.md
├── US01/
│   ├── STORY.md
│   ├── PRD/
│   └── PLAN/
└── TS01/
    ├── STORY.md
    ├── PRD/
    └── PLAN/
```

Leitura e gravação Classic SDD **somente** sob `features/NNN-slug/...` (repo ou global). Memory-bank co-localizado (`memory-bank/` no mesmo storage root). Pastas `PRD/` / `PLAN/` na raiz **não** fazem parte do fluxo ativo (só safety-net no `.gitignore` em modo repository). Em modo **global**, não editar `.gitignore`. Detalhes: `STORAGE.md` / `PIPELINE.md` / `MEMORY-BANK.md` após sync.

---

## CA7 - compatibilidade e exclusões deste MVP

**Dado** o toolkit sincronizado  
**Quando** você **não** usa Forma C  
**Então** skills Classic / Forma B / stack / operacional continuam invocáveis  

**Explicitamente fora deste PRD/MVP (histórico PRD 003):**

| Item | Status |
|------|--------|
| Spec Kit (`speckit-*`) | Removido do toolkit (PRD 004) - use Formas A / B / C |
| `memory-bank/` + Step 0 | Entregue (PRD 004) - gate só em `orchestrate-*`; Forma A isenta |
| Git worktrees multi-US | Fora |
| ADO / Celebration / Sonar corp. / Keycloak | Não portados |
| Blind review ×3 automático no loop de develop | Não |

Referência: PRD 003 § CA7, §14 Fora de escopo.

---

## Walkthrough: extração NuGet (cenário bf-ex)

Cenário ilustrativo - **não** exige app de produção neste repo. Objetivo: extrair biblioteca compartilhada X para NuGet interno; App A e App B consomem sem quebrar CI.

### Chat 1 - O1

```text
/orchestrate-analyze

Pedido: Extrair biblioteca compartilhada X para NuGet interno;
Apps A e B devem consumir o pacote sem quebrar CI.
```

Triage esperada (exemplo):

| Campo | Valor |
|-------|--------|
| Nature | `brownfield` |
| Complexity | `complex` |
| Scope | `backend` |
| needs_api / domain / security / devops | `true` (conforme flags) |
| needs_frontend / database | `false` (salvo persistência compartilhada) |

Especialistas típicos em paralelo: `repo_analyst`, `architect`, `security`.

Histórias de exemplo:

| Story | Conteúdo |
|-------|----------|
| TS01 | Extrair pacote + feed / publish CI |
| TS02 | App A como consumidor |
| TS03 | App B como consumidor |
| US01 *(opcional)* | Fluxo de publish para desenvolvedor |

Após **sim** no backlog:

```text
/orchestrate-deliver - features/004-nuget-extract/
```

### Chat 2 - O2 (paralelo)

Modo paralelo: um Task por história **rascunha** PRD/PLAN (sem Write em disco). Pai agrega -> aprovação humana -> pai grava via contratos `sdd-spec` / `sdd-plan`. Após aprovação, handoff típico:

```text
## Handoff O2 -> develop

Feature: features/004-nuget-extract/

| Story | PRD | PLAN |
|-------|-----|------|
| TS01 | features/004-nuget-extract/TS01/PRD/004_nuget_package.md | features/004-nuget-extract/TS01/PLAN/PLAN_004_nuget_package.md |
| TS02 | features/004-nuget-extract/TS02/PRD/004_app_a_consumer.md | features/004-nuget-extract/TS02/PLAN/PLAN_004_app_a_consumer.md |

### Manual (1 step por sessão)
/sdd-develop - features/004-nuget-extract/TS01/PLAN/PLAN_004_nuget_package.md - Step 1

### Orquestrado (O3)
/orchestrate-develop - features/004-nuget-extract/
```

### Chat 3+ - develop e review

- Preferir **uma história por vez** (ex.: TS01 até 100%, depois TS02).
- Após código: `/code-review` - passe `single`/`multi-angle` ou deixe a skill perguntar.
- Commit: `/commit` (após **sim**).

---

## Erros comuns

| Erro | Correção |
|------|----------|
| Pedir O2 sem aprovar backlog O1 | Voltar: `orchestrate-analyze - <path>` |
| Pai O3 implementar vários steps | Must-not; um subagente / um step |
| Usar Forma C para fix de uma linha | Usar `developer` / stack skill |
| Esperar worktrees neste MVP | Ver CA7 acima |
| Criar `memory-bank/` sob `features/` | Path errado - bank co-localiza com `features/` via manifest (`$Cwd/memory-bank/` ou `<classic.path>/memory-bank/`) |
| Assumir skip do Step 0 sem flag | Silêncio ≠ skip; use flag explícita |

---

## Relacionados

| Doc | Uso |
|-----|-----|
| [01-sdd-workflow.md](01-sdd-workflow.md) | Forma A |
| [03-code-review.md](03-code-review.md) | Review pós-develop |
| [05-operational-skills.md](05-operational-skills.md) | Forma B + commit |
| [AGENTS.md](../../AGENTS.md) | Router após sync |
| [SKILLS.md](../SKILLS.md) | Catálogo |
