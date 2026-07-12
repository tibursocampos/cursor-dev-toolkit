# Agent routing -> stack skills

Orchestrators and specialists **do not** reimplement stack work. Point implementation to existing developer skills.

| Signal | Route |
|--------|-------|
| `.cs` / `.csproj` / EF | `/dotnet-developer` |
| React / TSX | `/react-developer` |
| Angular | `/angular-developer` |
| Vue | `/vue-developer` |
| Blazor | `/blazor-developer` |
| Electron | `/electron-developer` |
| Node / plain JS | `/javascript-developer` |
| Python | `/python-developer` |
| Mixed / unclear | `/developer` (router) |
| UI shape / audit first | `/impeccable` -> DESIGN-BRIEF -> stack skill |
| Blip plugin scaffold | `/blip-plugin-developer` |

## Orchestrator boundaries

| Skill | May spawn | Must not |
|-------|-----------|----------|
| `orchestrate-analyze` | Roster specialists via Task | Call `*-developer` to write app code |
| `orchestrate-deliver` | Contracts of `sdd-spec` / `sdd-plan` per story | Implement code |
| `orchestrate-develop` | One subagent per PLAN step using `sdd-develop` contract | Parent writes app code; multi-step in one child |

**Memory-bank (Forma C Step 0):** after gate, pass resolved `bank_root` (`$Cwd/memory-bank/` or `<classic.path>/memory-bank/` per `STORAGE.md`) as **read-only** Prior context to specialists / O2 draft Tasks / O3 develop children (selective files). Do not place bank under `features/`. Forma A / manual `sdd-*` do not require the gate.

## Review

After O3 or manual develop: `/code-review` (name `- single` or `- multi-angle`, or let the skill ask - no silent default).
