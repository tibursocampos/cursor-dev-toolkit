# dotnet-developer

**Index:** [Guides README](README.md) · Router: [02-developer.md](02-developer.md)

---

## What it is

**`dotnet-developer`** is the toolkit shortcut for **small-to-medium .NET work** without a full SDD cycle. The agent loads Clean Architecture and C# guidelines on demand, works on a feature branch, runs `dotnet build` / `dotnet test`, and hands off to `commit` or `code-review`.

Use when the stack is **known to be .NET** or when `developer` routes here automatically.

---

## When to use / when not to use

### Use `dotnet-developer` when

- Isolated backend change (handler, repository, endpoint, test file).
- Low complexity - acceptance in a few sentences; no PRD needed.
- Repo has patterns to follow (Glob/Read similar code).

**Examples:** fix null reference in a validator; add DTO field and mapping; fix failing unit test.

### Do not use when

- EF migrations or broad schema changes -> `add-migrations` or SDD.
- Multiple bounded contexts or 3+ layers with new design.
- Cross-cutting feature, messaging, new integrations, 10+ files.
- Approved PLAN exists -> `sdd-develop`.

---

## Invoke examples

```
use skill dotnet-developer
```

```
use skill dotnet-developer - CreateUserValidator allows empty email; reject empty with FluentValidation message.
```

---

## Typical session

1. Open .NET solution in Cursor.
2. Invoke with description and acceptance criteria.
3. Agent creates/checks out `feature/<slug>`.
4. Implements with xUnit + Moq + FluentAssertions.
5. `dotnet build` and `dotnet test`.
6. `use skill code-review` -> `use skill test-coverage` -> `use skill commit`.

---

## SDD escalation

If scope grows during work (Forma A writes under `features/NNN-slug/US01/`):

```
use skill sdd-spec - [feature description]
use skill sdd-plan - features/NNN-slug/US01/PRD/...
use skill sdd-develop - features/NNN-slug/US01/PLAN/... - Step 1
```

---

## Related guidelines (lazy-loaded)

- `~/.cursor/skills/_shared/dotnet-guidelines/`
- `~/.cursor/skills/_shared/developer-common/`
- `~/.cursor/rules/branch-validation.mdc`
