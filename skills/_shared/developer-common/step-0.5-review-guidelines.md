# Step 0.5: Review code guidelines

**Required** before writing production code (~3-5 minutes). Reduces rework in review.

Load **only** what the task needs. Paths assume `scripts/sync-cursor.ps1` installed under `~/.cursor/skills/_shared/`.

---

## 1. Principles (always - one file)

Read a single principles file when available:

- `~/.cursor/skills/_shared/code-guidelines/principles/principles-cheatsheet.md`

If missing (before ETAPA 11), skip and rely on project `docs/` and stack guidelines below.

Do **not** glob all of `code-guidelines/`.

---

## 2. .NET (when `*.sln` or `*.csproj` in scope)

| Need | Path |
|------|------|
| Layers, handlers, repos | `~/.cursor/skills/_shared/dotnet-guidelines/clean-architecture.md` |
| Tests (xUnit, Moq, FluentAssertions, `Should_<R>_When_<C>`) | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` |
| **Structure and formatting** (one type per file, signatures/180 chars, constants, method order) | `~/.cursor/skills/_shared/dotnet-guidelines/csharp-patterns.md` - normative §§ File structure, Method signatures, Follow existing patterns, Named constants, Method ordering |
| Pre-PR gate | `~/.cursor/skills/_shared/dotnet-guidelines/checklist.md` |

Quick checks (always apply):

- [ ] No hardcoded secrets (keys, passwords, connection strings with real values)
- [ ] External input validated
- [ ] Parameterized queries - no string concatenation for SQL
- [ ] New packages checked for known vulnerabilities when adding dependencies

---

## 3. Other stacks

Use project `docs/` and the parent skill. Examples:

| Stack | Typical docs |
|-------|----------------|
| Angular / Node | `README`, `eslint` / `prettier` config |
| Python | `pyproject.toml`, `ruff` / `mypy` config |

---

## 4. Security (all stacks)

Scan staged changes for secret patterns before commit (see step 3.5). Placeholders (`<TOKEN>`, `YOUR_API_KEY`, `example`) are allowed in docs and samples.

---

## Expected output

```markdown
**Guidelines reviewed**

- Principles: [cheatsheet | skipped - not installed]
- Stack: [.NET | Angular | other] - [files loaded]
- Security: no hardcoded secrets in planned changes
- Next: branching (step 3) or implementation
```

---

## References

- Router: `AGENTS.md` in toolkit or target repo
- Token budget: do not preload `code-guidelines/languages/**`
