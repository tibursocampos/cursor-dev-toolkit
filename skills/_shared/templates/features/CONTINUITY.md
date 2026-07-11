# CONTINUITY: {{NNN}}-{{slug}}

| Campo | Valor |
|-------|--------|
| **Feature** | `features/{{NNN}}-{{slug}}/` |
| **Updated** | {{ISO8601}} |
| **Phase** | analyze \| deliver \| develop \| review |
| **Last agent** | {{AGENT_OR_SKILL}} |
| **Complexity** | trivial \| medium \| complex |
| **Nature** | greenfield \| brownfield \| operational |

## Estado atual

{{CURRENT_STATE}}

## Decisões

- {{DECISION}}

## Flags (`needs_*`)

| Flag | Valor |
|------|-------|
| needs_api | {{BOOL}} |
| needs_domain | {{BOOL}} |
| needs_database | {{BOOL}} |
| needs_frontend | {{BOOL}} |
| needs_security | {{BOOL}} |
| needs_devops | {{BOOL}} |

## Pendências

- [ ] {{OPEN_ITEM}}

## Handoff tipado

```text
{{NEXT_SKILL_INVOKE}}
```

## Contexto enxuto (pai)

Máx. síntese + paths. Detalhes ficam em `STORY.md` / `PRD` / `PLAN` / notas sob a história.

---

## Regras de atualização (agentes)

1. **Who updates:** every O1/O2/O3 stage and any specialist Task that finishes a meaningful note set.
2. **When:** before human approval gates; at ≥40% context pause; before session handoff.
3. **What to write:** phase, last agent, estado atual (≤10 lines), new decisões, open pendências, exact next `use skill …` string with **full paths**.
4. **What not to write:** full PRD/PLAN bodies, guideline dumps, application code.
5. **Merge:** append decisões; replace estado atual; never delete unresolved pendências without marking done.
6. **Language:** artifact prose default **pt-BR**; skill names and paths in English.
