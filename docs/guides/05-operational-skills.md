# Operational skills

**Index:** [Guides README](README.md)

---

## What it is

This guide collects **eight operational skills** that support day-to-day work after-or instead of-the main flows in guides [01](01-sdd-workflow.md)-[04](04-test-coverage.md). Each mini-manual gives the **invoke**, **when to use**, and **typical handoff**. None require external work-item APIs.

All skills run in the **open workspace**-the project you are building-not necessarily the `cursor-dev-toolkit` repo.

---

## When to use / when not to use

### Use these skills when

- You need to **commit**, fix a **broken build**, add an **EF migration**, document a **consumer repo for RAG**, refine a **backlog item**, break work into **task checklists**, or **scaffold a message consumer**.
- You already completed implementation and post-code steps-or you are unblocked on tooling/Git tasks.

### Do not substitute for

- **SDD** (`spec` -> `plan` -> `sdd-develop`) for medium/high complexity - [01 - SDD workflow](01-sdd-workflow.md).
- **`document-plan` / `document-implement`** for **this toolkit’s user guides** - those skills document **application repositories** for RAG. The manuals you are reading live in **`docs/guides/`** inside **cursor-dev-toolkit** and are maintained via SDD/sdd-develop on that repo (RN04).
- **`repair-dotnet-build`** when you want to **implement a new feature** - use [02 - developer](02-developer.md) or SDD instead.

---

## Prerequisites

1. **Toolkit installed** - [Install](../INSTALL.md), `scripts/sync-cursor.ps1`.
2. **Target repo open in Cursor** - the codebase you are changing.
3. **Agent mode** for skills that write files or run shell commands.
4. **Feature branch** for `commit` - `feature/<slug>` or `feat/<id>`; not `main`, `master`, or `develop`.
5. **Product doc language** - skills that write `docs/` in the **target app repo** ask **pt-BR** or **English** before saving (not applicable to editing toolkit `docs/guides/` from your consumer app).

---

## Skills at a glance

| Skill | Invoke |
|-------|--------|
| `commit` | `/commit` |
| `repair-dotnet-build` | `/repair-dotnet-build` |
| `ef-add-migration` | `/ef-add-migration` |
| `document-plan` | `/document-plan` |
| `document-implement` | `/document-implement` |
| `refine-story` | `/refine-story` |
| `split-story-checklist` | `/split-story-checklist` |
| `scaffold-message-handler` | `/scaffold-message-handler` |

---

## Mini-manuals

### commit

**Invoke:** `/commit`

**When to use:** After [code-review](03-code-review.md) and optional [test-coverage](04-test-coverage.md); you have staged or unstaged changes ready to land on a **valid feature branch**.

**Typical handoff:** Push and open a PR manually, or continue work in a new chat.

**Notes:** Drafts a **Conventional Commits** message, validates branch name, commits, and optionally pushes-does not auto-push unless you ask.

---

### repair-dotnet-build

**Invoke:** `/repair-dotnet-build`

**When to use:** `dotnet build` or `dotnet test` **already fails** locally or in CI; you need diagnosis and repair, not a greenfield feature.

**Typical handoff:** `/commit` once build and tests pass.

**Notes:** May use `gh` for GitHub Actions logs when helpful. Not a substitute for [developer](02-developer.md) when implementing new behavior.

---

### ef-add-migration

**Invoke:** `/ef-add-migration`  
Optional: `/ef-add-migration - AddOrderStatusColumn`

**When to use:** EF Core schema change in the open .NET repo; agent discovers startup project, `DbContext`, and migrations folder via Glob/Grep.

**Typical handoff:** `/sdd-develop - <plan-path> - Step N` if the change was a PLAN step, or `/commit`.

**Notes:** Run on a feature branch; review generated migration before commit.

---

### document-plan

**Invoke:** `/document-plan`  
Optional: path to an existing overview file after review.

**When to use:** You want a **documentation plan** for an **application repository** (RAG, onboarding, domain deep dives)-output includes `docs/documentation-plan/plan.md` and overview material in **that app repo**.

**Typical handoff:** `/document-implement` (one plan step per session).

**Not for:** Toolkit **user skill manuals** under `cursor-dev-toolkit/docs/guides/`-those are product docs of the toolkit itself, not consumer-app RAG docs.

---

### document-implement

**Invoke:** `/document-implement`

**When to use:** A `docs/documentation-plan/plan.md` already exists in the **target app repo** from `document-plan`; execute the **next pending** plan step only.

**Typical handoff:** New chat -> `/document-implement` for the following step, or `/commit` when a doc milestone is ready.

**Checkpoint:** One session = one plan step (same discipline as SDD `sdd-develop`).

---

### refine-story

**Invoke:** `/refine-story`

**When to use:** You have a rough bug, user story, or technical story and want structured markdown with BDD acceptance criteria and a quality scorecard (saved locally, optional under `docs/backlog/`).

**Typical handoff:** `/split-story-checklist`, `/sdd-spec` (Forma A), or `/orchestrate-analyze` (Forma C multi-story). Prefer story under `features/NNN-slug/USnn/` when using the new layout.

**Notes:** No external tracker API; output stays in your repo or chat until you commit.

---

### split-story-checklist

**Invoke:** `/split-story-checklist`

**When to use:** After `refine-story` (or similar input); group implementation steps into a checklist. Preferred path: under the story folder (`features/.../USnn/` or `TSnn/`). Shortcut: `docs/implementation-tasks/<slug>.md` (legacy alias `docs/sdd-developation-tasks/` still accepted).

**Typical handoff:** `/sdd-spec` / `/orchestrate-analyze` (complex / multi-story) - paste or reference the refined item and task file; or `/developer` for small scope.

**Notes:** Complements SDD / Forma C; does not replace PRD/PLAN for complex features. See [10-forma-c-orquestracao](10-forma-c-orquestracao.md).

---

### scaffold-message-handler

**Invoke:** `/scaffold-message-handler`

**When to use:** Scaffold a new **message consumer** in a .NET repo; agent detects MassTransit, RabbitMQ, or other bus via Grep-no fixed corporate template.

**Typical handoff:** `/developer` or `/sdd-develop` for remaining behavior, then `/commit`.

**Notes:** Collects requirements before codegen; bus-agnostic discovery.

---

## Suggested flows

Short sequences (Git-only, no work-item tracker)-details in [Install §4.4](../INSTALL.md#44-other-operational-skills):

**Consumer repo RAG documentation**

```
/document-plan
/document-implement
```

**Backlog -> SDD**

```
/refine-story
/split-story-checklist
/sdd-spec
/sdd-plan - <prd-path>
/sdd-develop - <plan-path> - Step 1
```

**Build failure -> land fix**

```
/repair-dotnet-build
/commit
```

**Post-code (from guides 01-04)**

```
/code-review
/test-coverage
/commit
```

---

## Common mistakes

1. **Using `document-plan` for toolkit guides** - That flow documents **your application** for RAG. **cursor-dev-toolkit** user manuals live in `docs/guides/` and are not created by `document-plan` in a random app repo.

2. **Multiple `document-implement` steps in one chat** - Same as SDD: one plan step per session keeps progress accurate in `docs/documentation-plan/plan.md`.

3. **Committing on `main` / `develop`** - `/commit` enforces branch rules; create `feature/<slug>` first.

4. **Calling `repair-dotnet-build` for new features** - If the build was green and you need new code, use [developer](02-developer.md) or SDD, not `repair-dotnet-build`.

5. **Skipping `refine-story` before `spec`** - You can go straight to `spec`, but vague requests produce weak PRDs; refinement improves acceptance criteria.

---

## Next step

| Situation | Guide / invoke |
|-----------|----------------|
| Full SDD pipeline | [01 - SDD workflow](01-sdd-workflow.md) |
| Small .NET change | [02 - developer](02-developer.md) |
| Review before commit | [03 - code-review](03-code-review.md) |
| Coverage gate | [04 - test-coverage](04-test-coverage.md) |
| Skill map and decision tree | [Guides README](README.md) |
| Install and sync | [../INSTALL.md](../INSTALL.md) |
