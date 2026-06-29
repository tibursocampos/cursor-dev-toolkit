# Git Flow and Workflow Guidelines

## Branching Strategy

Our teams primarily use a structured Git Flow based approach adapted for continuous delivery:

1. **Main Branch (`main` / `master`)**: Represents the official release history and the source of truth for deployments. Commits should not be made directly to `main`.
2. **Feature Branches**: For all new features, bug fixes, or chores. They should branch off `main` and be merged back via a Pull Request (PR).

Naming convention for branches:
- `feature/short-description`
- `fix/short-description`
- `chore/short-description`

## Pull Requests and Code Review

- **Small, Focused PRs**: Keep Pull Requests small and focused on a single responsibility. This makes them easier and faster to review.
- **Descriptive Titles and Summaries**: Include context, why the change was made, and how it was tested. Link the PR to the relevant issue tracker or task board ticket.
- **Approvals**: All PRs require at least one approval from a peer before merging. Some repositories (like the central GitOps repository) require specific CODEOWNERS approvals.

## Pre-Commit Hooks (Husky)

We heavily rely on Git pre-commit hooks to automate formatting and linting tasks, preventing unformatted or broken code from being committed.

- **Automated Formatting**: Tools like CSharpier, Prettier, or ESLint should be configured in pre-commit hooks.
- **Installation**: When cloning a repository for the first time, ensure you run the setup script or tool initialization (e.g., `dotnet husky install`, `npm run prepare`) so the local git hooks are configured correctly.
- **Bypassing**: Only bypass git hooks (using `--no-verify`) in absolute emergencies or when explicitly approved by a team lead.

> [!TIP]
> Always run your tests locally before opening a PR. Although CI/CD pipelines will catch failures, local testing saves time and CI resources.

---

## AI Stealth Policy

- **PR descriptions and commit messages** must not reference AI, generation, or automation. Write as a developer who owns the code.
- **No AI co-author trailers** (`Co-authored-by: GitHub Copilot` or similar).
- Output must be indistinguishable from work produced without AI assistance. See `GUARDRAILS.md` § 9.
