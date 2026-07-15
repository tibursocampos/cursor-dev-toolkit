# Guide 07: Caveman Mode

Optional response compression: shorter chat prose, same technical substance. Not roleplay — notices use ASCII `[Caveman]`.

Full contract: `skills/_shared/caveman/CAVEMAN.md`  
Always-on rule: `rules/caveman-mode.md` → `~/.cursor/rules/caveman-mode.mdc`  
Optional continuity/memory compact: `skills/_shared/caveman/COMPACT.md`

Inspired by [juliusbrussee/caveman](https://github.com/juliusbrussee/caveman) (portable ideas only).

## State

File: `~/.cursor/sdd/preferences.json`

```json
{
  "caveman_mode": false,
  "caveman_level": "full"
}
```

Commands:

| Command | Effect |
|---------|--------|
| `caveman on` | Enable mode (default level `full`) |
| `caveman off` / `stop caveman` / `normal mode` | Disable |
| `caveman status` | Report on/off + level |
| `caveman lite` / `full` / `ultra` | Set intensity (turns mode on if needed) |

## Intensity

| Level | Use when |
|-------|----------|
| **lite** | Planning / clarifying — full sentences, no filler |
| **full** | Default — telegraphic fragments |
| **ultra** | Long Forma C / review sessions only |

Skill **caps** still apply (Lite skills never escalate to ultra from prefs).

## Participation

| Cap | Skills |
|-----|--------|
| **NEVER** | `commit`, `push` |
| **LITE** | `sdd-spec`, `sdd-plan`, `orchestrate-analyze`, `orchestrate-deliver`, `document-plan`, `refine-story`, `memory-bank-init` |
| **FULL** | `sdd-develop`, `orchestrate-develop`, `document-implement`, `split-story-checklist`, `code-review`, `developer`, `repair-dotnet-build`, `test-coverage`, stack `*-developer`, ops (`api-integrate`, `containerize`, `i18n-manager`, `performance-profile`, `refactor`), general chat |

## Auto-Clarity

Drop compression for security warnings, irreversible confirms, ambiguous multi-step order, or when the user asks to clarify. Resume after.

## Never-compress

- Gates `(sim / ajustar / cancelar)`
- Artifact drafts (FEATURE, PRD, PLAN, CONTINUITY, …)
- Paths, commands, code blocks, safety/git alerts

## Honest cost

- Output prose can drop ~22–87% on verbose replies.
- Loading `CAVEMAN.md` adds ~1–1.5k **input** tokens per turn.
- Net-negative on short Q&A; prefer ON for long review/debug/orchestration.
- See [TOKEN_BUDGET.md](../TOKEN_BUDGET.md).

## Continuity compact

When narrative files dominate context, propose compacting `CONTINUITY.md` / memory-bank prose via `COMPACT.md` (backup `.original.md` + validators + `sim`). Never PRD/PLAN/STORY.

## Guardrails

Caveman does **not** bypass `guardrails.mdc`, session-state gates, or one-step-per-session limits.
