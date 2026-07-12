---
name: memory-bank-init
description: Create or refresh repository memory-bank/ (MVP contract + read-only inventory). No app code; no uv/specify. Use when invoking /memory-bank-init or Forma C Step 0 needs create/refresh.
---

## STOP - Read before ANY tool call

1. Read `~/.cursor/rules/guardrails.mdc`
2. Read `_shared/sdd-artifacts/SESSION.md`; load session-state for `$Cwd`
3. If the relevant gate is not approved: **STOP** - ask user **(pt-BR)** - do **NOT** Write/Shell
4. After create **or** refresh completes: **STOP** - handoff only (do not start O1/O2/O3 in this skill)
5. This skill body is **English**; user-facing prompts may be **(pt-BR)**

### Step -1 - Gate check (report in chat before continuing)

```
Gate check:
[ ] guardrails.mdc read
[ ] SESSION.md read; session-state loaded
[ ] MEMORY-BANK.md read
[ ] User confirmed current action (sim)
-> If any unchecked: STOP
```

---

# Skill: memory-bank-init

## Trigger

Invoke when the user asks for: `/memory-bank-init`, `init memory bank`, `refresh memory bank`, or when Forma C Step 0 (`MEMORY-BANK.md`) requires create/refresh.

Optional args: `create` (default if missing), `refresh`, path to consumer repo.

## Outcome

In the **consumer** workspace (`$Cwd`):

```text
memory-bank/
  project-context.md
  tech-stack.json
  architecture.md
  domain-knowledge.md
  conventions.md
  known-risks.md
  .inventory/
    sources.json
    gaps.md
    refresh-history.jsonl
```

**Does not** write application code. **Does not** install Python/uv/specify. **Does not** place the bank under `features/NNN-slug/`.

## Lazy-load

| When | Path |
|------|------|
| Gate policies, stale, versioning | `~/.cursor/skills/_shared/sdd-artifacts/MEMORY-BANK.md` |
| Templates | `~/.cursor/skills/_shared/templates/memory-bank/` |
| Inventory script | toolkit `scripts/inventory/Invoke-MemoryBankInventory.ps1` (or synced copy if present) |
| Fill patterns, markers | `skills/memory-bank-init/reference.md` |
| Context pressure | `~/.cursor/rules/context-management.mdc` |

## Process

### 1. Gate check

Report Step -1 checklist. Load `MEMORY-BANK.md`. **STOP** if unchecked.

### 2. Resolve target

1. Confirm **consumer** repo (not toolkit unless explicit).
2. Bank root = `$Cwd/memory-bank/` (never under `features/`).
3. Mode: **create** if bank missing/incomplete; **refresh** if user asked or Step 0 marked stale.

### 3. Confirm before write

Show (pt-BR): mode, full bank path, files to create/update. Ask:

`Posso gravar o memory-bank em '{path}'? (sim / ajustar / cancelar)`

Write only after **sim**.

### 4. Inventory (read-only scan)

Prefer script:

```powershell
.\scripts\inventory\Invoke-MemoryBankInventory.ps1 -RepoPath "<consumer>" -AllowCreateInventory
```

If script path unavailable in consumer, run equivalent Glob/Grep from `reference.md` and write **only** under `memory-bank/.inventory/`.

### 5. Scaffold or refresh files

| Mode | Action |
|------|--------|
| create | Copy templates from `templates/memory-bank/`; fill GENERATED regions + obvious fields from inventory/README/AGENTS |
| refresh | Re-run inventory; update GENERATED regions and `tech-stack.json`; preserve human prose outside markers |

Rules:

- Preserve `<!-- BEGIN GENERATED: … -->` / `<!-- END GENERATED: … -->` discipline (`reference.md`)
- **No secrets** - env names / `***` only
- Evidence-based domain/architecture; unknowns -> `gaps.md`
- Phase-2 contracts stay as gap lines only (no new required files)

### 6. Report + handoff

Report paths written, stack hints, blocking gaps (if any). Recommend consumer `.gitignore` entry:

```gitignore
memory-bank/.inventory/
```

(do not edit consumer `.gitignore` without confirm).

Handoff examples:

```text
/orchestrate-analyze
/memory-bank-init - refresh
```

## Must not

- Write application / test source
- Create bank under `features/NNN-slug/`
- Require external CLI tooling (uv, specify, Spec Kit installers)
- Skip confirm-before-write
- Dump entire bank into orchestrator parent context
- Auto-commit
