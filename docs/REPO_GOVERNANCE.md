# Repository governance

Public toolkit: **clone and fork allowed**; **no community contributions** (no upstream PRs from outsiders). Write access and internal PRs are **owner / collaborators only**.

## GitHub settings (owner checklist)

Apply **per repository** (Settings or `gh` with admin token):

- [ ] **Pull requests** → **Collaborators only** (not disabled — owner keeps internal PR flow)
- [ ] Repository write / admin: **owner only** (no outside collaborators unless you choose)
- [ ] No direct pushes to `develop` or `master`/`main` (rulesets or branch protection)
- [ ] Internal PRs: `feature/*` / `feat/*` → `develop`
- [ ] `master`/`main` only from `develop`
- [ ] Required status check: job **`validate`** (workflow Validate toolkit)

Reference: [Disabling / restricting pull requests](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/disabling-pull-requests).

## Branch model (maintainers)

| Branch | Role |
|--------|------|
| `feature/<slug>` or `feat/<id>` | Owner work branches |
| `develop` | Integration; default internal PR target |
| `master` / `main` | Release / stable; updated from `develop` |

Aligns with `rules/branch-validation` and `/commit` / `/push` skills.

## Required checks

GitHub Actions workflow **Validate toolkit** job **`validate`** must pass on maintainer PRs and pushes (per workflow triggers).

## Public policy

| Audience | Clone / fork | Open PR here | Push |
|----------|--------------|--------------|------|
| Public | Yes | No | No |
| Owner / collaborators | Yes | Yes (internal) | Yes |

Policy for users: [CONTRIBUTING.md](../CONTRIBUTING.md). Internal PR template: [.github/PULL_REQUEST_TEMPLATE.md](../.github/PULL_REQUEST_TEMPLATE.md).
