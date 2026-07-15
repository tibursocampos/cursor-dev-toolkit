# Repository governance

Public toolkit repo: **anyone can clone/fork**; **write access is owner-only**. Contributions land via pull request from forks.

## Branch model

| Branch | Role |
|--------|------|
| `feature/<slug>` or `feat/<id>` | Contributor / owner work branches |
| `develop` | Integration; default PR target |
| `master` / `main` | Release / stable; updated only from `develop` |

Do **not** push commits directly to `develop` or `master`/`main`. Aligns with `rules/branch-validation` and `/commit` / `/push` skills.

## Required checks

GitHub Actions workflow **Validate toolkit** job **`validate`** must pass on PRs.

## Rulesets checklist (owner applies in GitHub Settings or `gh`)

Apply **per repository** (owner token / admin). Outsiders cannot change rulesets.

- [ ] No direct pushes to `develop` or `master`/`main`
- [ ] PRs from `feature/*` / `feat/*` → `develop`
- [ ] `master`/`main` only accept merges from `develop`
- [ ] Required status check: job name **`validate`** (workflow Validate toolkit)
- [ ] Repository write / admin: **owner only**
- [ ] Outside contributors: fork + PR only

Optional: `CODEOWNERS` with the owner login if you want review assignment.

## Contributor entry points

- [CONTRIBUTING.md](../CONTRIBUTING.md)
- [.github/PULL_REQUEST_TEMPLATE.md](../.github/PULL_REQUEST_TEMPLATE.md)
