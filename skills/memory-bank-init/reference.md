# memory-bank-init - reference

Companion to `SKILL.md`. Contract authority: `_shared/sdd-artifacts/MEMORY-BANK.md`.

## Template map

| Template | Target |
|----------|--------|
| `templates/memory-bank/project-context.md` | `memory-bank/project-context.md` |
| `templates/memory-bank/tech-stack.json` | `memory-bank/tech-stack.json` |
| `templates/memory-bank/architecture.md` | `memory-bank/architecture.md` |
| `templates/memory-bank/domain-knowledge.md` | `memory-bank/domain-knowledge.md` |
| `templates/memory-bank/conventions.md` | `memory-bank/conventions.md` |
| `templates/memory-bank/known-risks.md` | `memory-bank/known-risks.md` |
| `templates/memory-bank/.inventory/*` | `memory-bank/.inventory/*` |

Replace `{{PLACEHOLDERS}}` with evidenced values or `TBD` + gap entry. Never invent product domain names.

## Generated region markers

```markdown
<!-- BEGIN GENERATED: inventory-summary -->
…machine content…
<!-- END GENERATED: inventory-summary -->
```

On **refresh**:

1. Re-run inventory -> update `.inventory/`.
2. Replace only content **inside** matching BEGIN/END pairs.
3. Leave human prose outside markers intact.
4. Append one JSON line to `refresh-history.jsonl` (`at`, `action`, `repo`, `hints`).

If markers missing in an old file: add markers around the inventory summary block once; do not wipe the whole file.

## tech-stack.json fill

From inventory `stack_hints` + manifests:

| Hint | languages / frameworks examples |
|------|----------------------------------|
| node | `javascript`/`typescript`; frameworks from package.json deps if read |
| dotnet | `csharp`; `aspnet` / `efcore` if csproj evidence |
| python | `python`; FastAPI/Flask if pyproject/requirements mention |
| go / rust | as detected |

`generated_at` must match inventory run (ISO-8601 UTC).

## Manual inventory fallback (no script)

If `Invoke-MemoryBankInventory.ps1` is unreachable:

1. Glob lockfiles / manifests listed in `MEMORY-BANK.md` stale section.
2. Write `sources.json` with `path`, `last_write_utc`, `length` per file.
3. Write `gaps.md` with MVP checklist + phase-2 hints (openapi / migrations / package.json -> ui).
4. Append `refresh-history.jsonl`.

Still **write only** under `memory-bank/.inventory/`.

## Secrets checklist

Refuse to copy into bank:

- Connection strings, API keys, tokens, passwords
- Raw `.env` values, private keys, feed credentials
- Personal data

Use: `ConnectionStrings__Default` (name only), `***`, or “see secret store”.

## Versioning note (for guides)

| Commit in consumer | Usually ignore |
|--------------------|----------------|
| `project-context.md`, `architecture.md`, `domain-knowledge.md`, `conventions.md`, `known-risks.md`, `tech-stack.json` | `memory-bank/.inventory/` |

## Dry-run mental tests (CA5)

| Situation | Expected |
|-----------|----------|
| No `memory-bank/` + policy auto | create after confirm |
| Healthy bank, fresh inventory | skip write; status `fresh` |
| Lockfile newer than `sources.json` | stale -> refresh after confirm |
| Inventory script | does not touch files outside `memory-bank/.inventory/` (and skill may create sibling bank markdown) |
