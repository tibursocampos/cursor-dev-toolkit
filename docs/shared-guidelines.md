# Shared guidelines

Shared guidelines live under `skills/_shared/` and are loaded lazily by skills (not preloaded into chat).

## SDD runtime

| Path | Purpose |
|------|---------|
| `sdd-artifacts/STORAGE.md` | Manifest v2, storage resolution, naming |
| `sdd-artifacts/PIPELINE.md` | Stage order, missing-artifact prompts |
| `sdd-artifacts/SESSION.md` | Session gates schema |

## Developer flow

| Path | Purpose |
|------|---------|
| `developer-common/GUIDE.md` | Git-only developer workflow overview |
| `developer-common/step-*.md` | Branching, pre-commit, commits, checklist |
| `format-validators/` | Commit/PR/feature format validators |

## Stack guidelines

| Folder | Purpose |
|--------|---------|
| `dotnet-guidelines/` | Clean Architecture, C#, formatting, NuGet, checklist |
| `react-guidelines/` | React patterns, philosophies, performance |
| `angular-guidelines/` | Angular styleguide, signals, best practices |
| `javascript-guidelines/` | JS/TS clean code, strict TypeScript, DOM patterns |
| `vue-guidelines/` | Vue 3 Composition API, routing, state, testing |
| `blazor-guidelines/` | Blazor components, state, testing (WASM/Server/Hybrid) |
| `electron-guidelines/` | Main/preload/renderer, security, packaging |
| `html-css-guidelines/` | Semantic HTML, CSS foundations, SCSS |
| `frontend-guidelines/` | Cross-stack frontend core (`frontend-practices.md`) and testing |
| `blip-guidelines/` | Blip plugin architecture, BDS, iframe messages, auth, external API, deploy/CI |
| `python-guidelines/` | Python style and principles |
| `git-guidelines/` | Git flow |
| `devops-guidelines/` | Deployment and GitOps |

## Universal principles

`code-guidelines/principles/` - SOLID, DRY, KISS, YAGNI, encapsulation, cheatsheet.

## Backlog types

`backlog-item-types/` - bug, user-story, technical-story templates.

## Caveman Mode

`caveman/CAVEMAN.md` - compression tiers and hard exclusions.

## Language split

| Context | Language |
|---------|----------|
| Chat replies | pt-BR (`user-language-pt-br.mdc`) |
| Skill/guideline files | English |
| Code, tests, identifiers | English |
| SDD artifacts (default) | pt-BR |

## Validation

After adding or changing shared files:

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validation\validate-all.ps1
```
