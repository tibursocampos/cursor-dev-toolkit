# Guide 08: Stack developer skills

Stack-specific skills for small-to-medium work **without** a full SDD cycle. Use when the stack is known or when `developer` routes to one of these skills automatically.

## Skills

| Skill | Invoke | When |
|-------|--------|------|
| `dotnet-developer` | `use skill dotnet-developer` | `.sln` / `.csproj`, isolated .NET change |
| `react-developer` | `use skill react-developer` | React app, component/hook work |
| `angular-developer` | `use skill angular-developer` | Angular app, components/services |
| `javascript-developer` | `use skill javascript-developer` | Node/JS/TS without React/Angular |
| `python-developer` | `use skill python-developer` | Python services, scripts, FastAPI/Flask |

## Router vs explicit invoke

- **`use skill developer`** - inspects the workspace and delegates silently to the matching stack skill.
- **`use skill dotnet-developer`** (etc.) - skip detection; use when you already know the stack.

See [02-developer.md](02-developer.md) for the router and [02b-dotnet-developer.md](02b-dotnet-developer.md) for .NET-specific detail.

## When to escalate to SDD

Use `sdd-spec` -> `sdd-plan` -> `sdd-develop` (or Spec Kit chain) when **two or more** apply:

- 3+ architectural layers touched
- Schema/migration changes
- Cross-repo or new integrations
- 10+ files or 4+ hours estimated
- Approved PLAN already exists

## Engineering utilities (any stack)

For cross-cutting utilities, see [05-operational-skills.md](05-operational-skills.md):

- `refactor`, `api-integrate`, `performance-profile`, `containerize`, `i18n-manager`

These may hand off to `developer` (router) or a stack skill for local edits.

## Post-code workflow

On a valid feature branch:

1. `use skill code-review`
2. `use skill test-coverage` (.NET repos with tests)
3. `use skill commit`
