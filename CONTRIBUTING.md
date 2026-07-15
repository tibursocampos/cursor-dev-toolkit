# Contributing

Thanks for contributing to **cursor-dev-toolkit**. This repository is **public**; write access stays with the owner. Outsiders contribute via **fork → pull request**.

## Workflow

1. Fork the repo and clone your fork.
2. Create a branch: `feature/<slug>` or `feat/<id>` (never commit on `main` / `master` / `develop`).
3. Make changes. Keep skill bodies in **English**; user-facing prompts may be **pt-BR**.
4. Run validation from repo root:

   ```powershell
   .\scripts\toolkit.ps1
   # or
   .\scripts\sync-cursor.ps1
   .\scripts\validation\validate-all.ps1
   ```

   On Unix with PowerShell 7+: `./scripts/toolkit.sh`

5. Open a PR targeting **`develop`** (not `master` directly).
6. Wait for the required GitHub Actions check **`validate`** to pass.

## Scope

- Skills, rules, hooks, docs, and validation scripts belong here.
- Do not add org-only tracker/IdP playbooks or secrets.
- Prefer small, reviewable PRs.

## More

- Branch and PR rules: [docs/REPO_GOVERNANCE.md](docs/REPO_GOVERNANCE.md)
- Install: [docs/INSTALL.md](docs/INSTALL.md)
- Skill catalog: [docs/SKILLS.md](docs/SKILLS.md)
