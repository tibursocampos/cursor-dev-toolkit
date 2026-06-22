# speckit-plan - reference

Templates for `skills/speckit-plan/SKILL.md`. Keep `SKILL.md` under 500 lines; use this file for extended detail.

## plan.md template (pt-BR content, English identifiers)

```markdown
# Plano: NNN - <Titulo>

## Spec de Referencia
{path to spec.md}

## Design Tecnico
<Abordagem e decisoes arquiteturais>

## Arquivos Afetados
| Acao | Arquivo |
|---|---|
| CRIAR | path/to/file |
| MODIFICAR | path/to/file |

## Escopo
### Incluso
- <item>

### Excluido
- <item>

## Riscos
- <risco>

## Status
0/{N} tarefas concluidas
```

## tasks.md template (pt-BR content, English identifiers)

```markdown
# Tasks: NNN - <Titulo>

## Referencias
- Spec: {path to spec.md}
- Plan: {path to plan.md}

## Tarefas

- [ ] **Task 1** - <descricao clara em uma linha>
  - Contexto: <o que fazer e por que>
  - Arquivos: <file1>, <file2>

- [ ] **Task 2** - <descricao>
  ...
```
