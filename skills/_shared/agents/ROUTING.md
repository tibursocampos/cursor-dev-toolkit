# Agent routing -> stack skills

Orchestrators and specialists **do not** reimplement stack work. Point implementation to existing developer skills.

| Signal | Route |
|--------|-------|
| `.cs` / `.csproj` / EF | `use skill dotnet-developer` |
| React / TSX | `use skill react-developer` |
| Angular | `use skill angular-developer` |
| Vue | `use skill vue-developer` |
| Blazor | `use skill blazor-developer` |
| Electron | `use skill electron-developer` |
| Node / plain JS | `use skill javascript-developer` |
| Python | `use skill python-developer` |
| Mixed / unclear | `use skill developer` (router) |
| UI shape / audit first | `use skill impeccable` -> DESIGN-BRIEF -> stack skill |
| Blip plugin scaffold | `use skill blip-plugin-developer` |

## Orchestrator boundaries

| Skill | May spawn | Must not |
|-------|-----------|----------|
| `orchestrate-analyze` | Roster specialists via Task | Call `*-developer` to write app code |
| `orchestrate-deliver` | Contracts of `sdd-spec` / `sdd-plan` per story | Implement code |
| `orchestrate-develop` | One subagent per PLAN step using `sdd-develop` contract | Parent writes app code; multi-step in one child |

## Review

After O3 or manual develop: `use skill code-review` (name `- single` or `- multi-angle`, or let the skill ask — no silent default).
