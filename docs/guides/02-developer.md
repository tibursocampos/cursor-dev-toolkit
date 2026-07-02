# developer router

**Index:** [Guides README](README.md) · .NET detail: [02b-dotnet-developer.md](02b-dotnet-developer.md)

---

## What it is

**`developer`** is the **hybrid router** skill. It inspects the open workspace, delegates to the correct stack skill when a framework is detected, or implements ad-hoc scripts/HTML/automation directly when no stack matches.

It does **not** replace SDD for medium/high-complexity work.

---

## When to use

| Use `developer` when | Prefer SDD or stack skill when |
|----------------------|--------------------------------|
| Stack unclear; let agent detect | You know it's .NET -> `dotnet-developer` |
| Mixed/small task; router is fine | Migrations, 3+ layers, cross-repo |
| Ad-hoc `.ps1`, `.sh`, `.html` | Approved PLAN exists -> `sdd-develop` |

---

## Routing behavior

Detection order (first match wins). See [08-stack-developers.md](08-stack-developers.md) for the full table.

| Detected | Delegates to |
|----------|--------------|
| User asks for **new** Blip plugin (no repo yet) | `blip-plugin-developer` |
| `blip-ds` + `iframe-message-proxy` in `package.json` | `react-developer` (+ `blip-guidelines/`) |
| Blazor markers (`.csproj`, `App.razor`, …) | `blazor-developer` |
| Electron in `package.json` | `electron-developer` |
| Vue in `package.json` | `vue-developer` |
| React in `package.json` | `react-developer` |
| Angular in `package.json` | `angular-developer` |
| Generic `package.json` (Node) | `javascript-developer` |
| `.csproj` / `.sln` (no Blazor) | `dotnet-developer` |
| Python project files | `python-developer` |
| No framework match | Fallback: implement directly |

Delegation is **silent** - the agent loads the stack skill without asking.

---

## Invoke examples

```
use skill developer
```

```
use skill developer - fix the login form validation in this React app
```

For explicit .NET work without detection:

```
use skill dotnet-developer
```

See [08-stack-developers.md](08-stack-developers.md) for all stack skills.

---

## Typical session

1. Open target project in Cursor.
2. Invoke `use skill developer` with a concise description.
3. Agent runs gate check, detects stack, implements.
4. Run tests/build per stack skill.
5. `use skill code-review` -> optional `test-coverage` (.NET) -> `use skill commit`.

---

## Must not expect

- Automatic git commit (use `commit` after confirmation)
- Multi-step PLAN execution in one session (use `sdd-develop`)
- Persona skill (`dev_persona`) - Cursor uses `rules/` + `AGENTS.md` instead

---

## Related

| Doc | Content |
|-----|---------|
| [02b-dotnet-developer.md](02b-dotnet-developer.md) | .NET-only workflow |
| [08-stack-developers.md](08-stack-developers.md) | All stack skills |
| [01-sdd-workflow.md](01-sdd-workflow.md) | Full SDD path |
