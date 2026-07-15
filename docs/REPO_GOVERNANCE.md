# Repository governance

Public toolkit: **clone and fork allowed**; **no community contributions** (no upstream PRs from outsiders). Write access and internal PRs are **owner / collaborators only**.

Apply settings **per repository** in the GitHub **web UI** (Settings). No GitHub CLI required.

## Branch model (maintainers)

| Branch | Role |
|--------|------|
| `feature/<slug>` or `feat/<id>` | Owner work branches |
| `develop` | Integration; default internal PR target |
| `master` / `main` | Release / stable; updated from `develop` |

Aligns with `rules/branch-validation` and `/commit` / `/push` skills.

```text
feature/* or feat/*  →  PR + validate  →  develop  →  PR + validate  →  master / main
```

## GitHub settings (owner checklist)

Mark each box after you apply it in the UI for this repository.

### A. Collaborators only

- [ ] **Settings** → **General** → **Pull Requests** → enable **Allow pull requests from collaborators only** (or equivalent “Collaborators only”)
- [ ] Repository remains **Public** (clone/fork still OK)
- [ ] Repository write / admin: **owner only** (no outside collaborators unless you choose)

Reference: [Restricting pull requests](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/disabling-pull-requests).

### B. Ruleset `protect-develop`

- [ ] **Settings** → **Rules** → **Rulesets** → **New branch ruleset**
- [ ] **Ruleset name:** `protect-develop`
- [ ] **Enforcement status:** Active
- [ ] **Bypass list:** empty (prefer no bypass; add yourself as Admin only for emergencies)
- [ ] **Target branches** → **Add target** → **Include by name** → `develop`
- [ ] **Restrict deletions**
- [ ] **Block force pushes**
- [ ] **Require a pull request before merging** — Required approvals: **0** (solo owner); dismiss stale reviews: on; code owner review: off
- [ ] **Require status checks to pass** — Require branches to be up to date: on; add check: **`validate`**
- [ ] Save / Create

If `validate` is not listed: open a PR into `develop` (or push a branch that triggers CI) so the workflow runs once, then edit the ruleset and add the check.

### C. Ruleset `protect-release`

- [ ] New branch ruleset named `protect-release`
- [ ] **Enforcement status:** Active; **Bypass list:** empty (same preference as develop)
- [ ] **Target branches:** Include by name → `master` **and** Include by name → `main`
- [ ] Same rules as B: restrict deletions, block force pushes, require PR (0 approvals), require status check **`validate`** (up to date)
- [ ] Save / Create

### D. Release source gate (in repo)

Workflow [`.github/workflows/enforce-release-source.yml`](../.github/workflows/enforce-release-source.yml) fails PRs into `master`/`main` unless the head branch is `develop`. Rulesets alone cannot filter the source branch.

- [ ] Workflow present on the default branch
- [ ] Optional: after the first green run, add required check **`release-source`** to `protect-release`

### E. Verify

- [ ] Direct push to `develop` is rejected
- [ ] PR `feature/…` or `feat/…` → `develop` merges only after **`validate`** is green
- [ ] PR `develop` → `master` or `main` is allowed
- [ ] PR from any other branch → `master`/`main` fails **`release-source`**

## Required checks

| Check | Workflow / job | Used on |
|-------|----------------|---------|
| `validate` | Validate toolkit → job `validate` | PRs/pushes to `develop`, `master`, `main` |
| `release-source` | Enforce release source → job `release-source` | PRs targeting `master` / `main` |

## Public policy

| Audience | Clone / fork | Open PR here | Push |
|----------|--------------|--------------|------|
| Public | Yes | No | No |
| Owner / collaborators | Yes | Yes (internal) | Yes (via PR to protected branches) |

Policy for users: [CONTRIBUTING.md](../CONTRIBUTING.md). Internal PR template: [.github/PULL_REQUEST_TEMPLATE.md](../.github/PULL_REQUEST_TEMPLATE.md).
