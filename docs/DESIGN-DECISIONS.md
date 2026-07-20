# Design decisions

Short rationale for future maintainers (single-owner toolkit). Prefer updating this when changing a “why”, not only a “how”.

## DD-001 — Three Formas (A / B / C), not one pipeline

**Decision:** Keep Classic SDD (A), backlog prep (B), and orchestration (C) as coexisting entry points.

**Why:** One-size SDD over-taxes small fixes; pure chat under-disciplines large brownfield work. Users pick complexity explicitly.

**Consequence:** Docs and the decision tree must teach all three; install quick start must not sell only Forma A.

## DD-002 — Orchestrators reuse `sdd-*` contracts

**Decision:** O2 loads `sdd-spec` / `sdd-plan` contracts; O3 loads `sdd-develop` (one PLAN step). Orchestrators never write application code in the parent.

**Why:** Avoid forking PRD/PLAN/develop quality rules. Manual `/sdd-develop` remains a valid alternative to O3.

**Consequence:** Skill contracts and fixtures assert reuse markers; changing Classic SDD automatically affects Forma C.

## DD-003 — PowerShell as the automation language

**Decision:** Canonical scripts are `.ps1`; Unix uses `pwsh` via `.sh` wrappers.

**Why:** One implementation for Win/macOS/Linux; matches maintainer environment; avoids dual bash/ps1 drift.

**Consequence:** Contributors need PowerShell 7+. Documented in PORTABILITY.md; not a bash rewrite target unless requirements change.

## DD-004 — No GitHub CLI in skills

**Decision:** Skills use `git` only; PRs and CI log fetch go through the **GitHub web UI** / pasted logs.

**Why:** Corporate environments often block or omit the GitHub CLI; automated PR create is easy to misuse against branch policy.

**Consequence:** Validators forbid GitHub CLI invoke patterns (for example pr/run subcommands) in docs and skills.

## DD-005 — Fork-only public repos

**Decision:** Public clone/fork OK; no community PR acceptance (see CONTRIBUTING.md).

**Why:** Personal toolkit; guardrails and skill semantics are opinionated; review bandwidth is unipersonal.

**Consequence:** Continuity risk — mitigate with this file, PORTABILITY.md, and smoke/contract tests rather than community bus-factor.

## DD-006 — Independent toolkit (no public sibling sync policy)

**Decision:** This repository does not document or depend on any other IDE toolkit.

**Why:** A published cross-toolkit sync policy caused drift and confused newcomers; each IDE product owns its packaging.

**Consequence:** Manual ports (if any) stay private operator notes — never in-repo references to sibling toolkits.

## DD-007 — Global profile deploy with backup

**Decision:** Sync writes under `~/.cursor/`; sync creates a timestamped backup; restore script rolls back.

**Why:** Shared global skills affect every Cursor project — a bad sync is high blast radius.

**Consequence:** Document rollback; include backup existence checks in validation where practical.
