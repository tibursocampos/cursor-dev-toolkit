# Impeccable integration (cursor-dev-toolkit)

Upstream: [pbakaus/impeccable](https://github.com/pbakaus/impeccable) - vendored at `skill-v3.9.1` via `skills/impeccable/reference/`. **Not** the Antigravity persona skills.

## Three levels (do not confuse)

| Level | What | Project install? |
|-------|------|------------------|
| **1 - Toolkit skill** | `use skill impeccable` + lazy-loaded `reference/<cmd>.md` | **No** - synced to `~/.cursor/skills/impeccable/` |
| **2 - Detector bridge** | `npx impeccable detect --json <paths>` during `audit` | **No** - transient npx |
| **3 - Per-project setup** | `npx impeccable install` (live mode, design hook, `.impeccable/`) | **Yes** - explicit user consent only |

Daily shape -> brief -> implement **does not** require level 3.

## Invoke

```
use skill impeccable
use skill impeccable shape [feature]
use skill impeccable audit [paths]
```

Aliases: `impeccable-shape`, `impeccable-audit` map to the same router.

## Handoff contract

1. `impeccable shape` (or craft shape phase) -> user confirms -> `docs/DESIGN-BRIEF.md`
2. New session -> `react-developer`, `angular-developer`, `javascript-developer`, or `developer` router
3. Implementer reads brief; does not redesign in the same session

Template: `skills/impeccable/reference/DESIGN-BRIEF-TEMPLATE.md`

**Blip plugins:** when `target_stack` is `react` and the project uses `blip-ds`, add BDS / iframe constraints in brief section 9. For new Blip extensions, prefer `use skill blip-plugin-developer` for scaffold before `impeccable shape`. See [blip-plugin-integration.md](blip-plugin-integration.md).

## When `npx impeccable install` is needed

| Scenario | Install? |
|----------|----------|
| shape / polish / critique with toolkit refs | No |
| `npx impeccable detect` in audit | No |
| **Live mode** (browser variants) | Yes |
| **Design hook** (block slop on UI writes) | Yes |
| Shared `.impeccable/config.json` in repo | Yes |

The skill **must ask (pt-BR)** before running install. Never silent.

## Hook coexistence (toolkit + Impeccable)

Toolkit hooks (SDD session, PLAN checkpoint) live in `~/.cursor/hooks.json` after `sync-cursor.ps1`. Impeccable install adds project-level `.cursor/hooks.json` with `hook-before-edit.mjs`.

**Merge strategy:**

1. Back up existing `.cursor/hooks.json` in the target project.
2. Run `npx impeccable install` only after user confirms.
3. Merge hook entries additively (same pattern as `sync-cursor.ps1` - do not overwrite unrelated events).
4. See toolkit [HOOKS.md](HOOKS.md) for SDD hooks; Impeccable hook docs in `skills/impeccable/reference/hooks.md`.

## Project `.gitignore` snippet

Add to frontend projects using Impeccable artifacts:

```gitignore
# impeccable-ignore-start
.impeccable/config.local.json
.impeccable/hook.cache.json
.impeccable/hook.pending.json
.impeccable/*.png
.impeccable/live/server.json
.impeccable/live/sessions/
.impeccable/live/previews/
.impeccable/live/annotations/
.impeccable/live/cache/
.impeccable/live/manual-edit-apply-transaction.json
.impeccable/live/manual-edit-events.jsonl
.impeccable/live/manual-edit-evidence/
.impeccable/live/pending-manual-edits.json
.impeccable/live/deferred-svelte-component-accepts.json
.impeccable/live/*.png
# impeccable-ignore-end
```

**Keep tracked:** `.impeccable/config.json`, `.impeccable/live/config.json`, `.impeccable/design.json`, `.impeccable/critique/*.md`

## Maintainer sync

Refresh references from local upstream clone:

```powershell
.\scripts\maintainers\sync-impeccable-refs.ps1
.\scripts\maintainers\sync-impeccable-refs.ps1 -SourcePath D:\Source\Repos\impeccable -Tag skill-v3.9.1
```

Preserves toolkit-only files: `DESIGN-BRIEF-TEMPLATE.md`.

## Validation

```powershell
.\scripts\validation\validate-impeccable-skill.ps1
```

Bundled with `validate-all.ps1`.

## Alternative: upstream-only install

Teams that prefer zero vendoring can run `npx impeccable install` in each project and skip the toolkit skill. The toolkit router still recommends `impeccable shape` before `*-developer` when `PRODUCT.md` is missing.
