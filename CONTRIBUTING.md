# Repository policy

**cursor-dev-toolkit** is a **public, read-only** toolkit: anyone may **clone** or **fork** and use it locally. **Upstream contributions are not accepted** — do not open pull requests to this repository.

## For everyone (clone / fork)

You may:

- Clone or fork this repo for personal or team use
- Sync skills to `~/.cursor/` and use them in your projects
- Customize skills, rules, and docs **in your fork** (or a private copy)

You may **not**:

- Open pull requests expecting review or merge into this repo
- Request write access for community contributions

Changes you want to keep belong in **your fork** (or your own toolkit copy), not here.

### Install and validate (your copy)

```powershell
# Windows
.\scripts\toolkit.ps1
```

```bash
# macOS / Linux (PowerShell 7+)
./scripts/toolkit.sh
```

Or sync directly:

```powershell
.\scripts\sync-cursor.ps1
.\scripts\validation\validate-all.ps1
```

See [docs/INSTALL.md](docs/INSTALL.md) and [docs/SKILLS.md](docs/SKILLS.md).

## Maintainers only (repository owner)

Internal development uses the normal Git flow on branches with write access:

| Branch | Role |
|--------|------|
| `feature/<slug>` or `feat/<id>` | Work branches |
| `develop` | Integration |
| `master` / `main` | Stable release |

Pull requests are **collaborators only** (GitHub: Settings → Features → Pull requests → **Collaborators only**). Outsiders cannot open PRs; the owner keeps `develop` / `master` rules and required CI check **`validate`**.

Details: [docs/REPO_GOVERNANCE.md](docs/REPO_GOVERNANCE.md).
