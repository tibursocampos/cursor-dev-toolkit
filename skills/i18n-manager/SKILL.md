---
name: i18n-manager
description: >
  Scan files for hardcoded string literals, extract them into resource localization files (.resx or .json),
  and replace them with dynamic translation keys. Use when the user says "use skill i18n-manager",
  "localize code", or "/i18n-manager".
---

## STOP - Read before ANY tool call

1. Read `~/.cursor/rules/guardrails.mdc`
2. Read `~/.cursor/skills/_shared/sdd-artifacts/SESSION.md`; load session-state for `$Cwd`
3. If the relevant gate is not approved: **STOP** - ask user **(pt-BR)** - do **NOT** Write/Shell
4. SDD/develop skills: after **ONE** step/task, **STOP** session - handoff only
5. This skill body is **English**; user-facing prompts may be **(pt-BR)**

### Step -1 - Gate check (report in chat before continuing)

```
Gate check:
[ ] guardrails.mdc read
[ ] SESSION.md read; session-state loaded
[ ] PIPELINE.md read (SDD/speckit skills only)
[ ] User confirmed current action (sim)
-> If any unchecked: STOP
```

---

# Skill: i18n-manager

## Trigger

Invoke when the user requests: `use skill i18n-manager`, `localize code`, `/i18n-manager`, or asks to internationalize a component.

**Arguments (optional):**

| Input | Meaning |
|-------|---------|
| Target directory | Scopes the scan for string literals to a specific subfolder |

## Outcome

1. Refactored code files where raw strings are replaced by framework-native translation variables or helpers (e.g. `_localizer["Key"]`, `t('Key')`).
2. Updated localization resource files (`.resx` for C#, `.json` translation dictionaries for JavaScript/TypeScript).

## Lazy-load

| When | Path (after `scripts/sync-cursor.ps1`) |
|------|----------------------------------------|
| C# projects | `~/.cursor/skills/_shared/dotnet-guidelines/string-manipulation.md` |
| React / Angular | `~/.cursor/skills/_shared/frontend-guidelines/frontend-practices.md` |
| Caveman Mode (if active) | `~/.cursor/skills/_shared/caveman/CAVEMAN.md` - Full mode |

## Process

### -1. Re-check guardrails and session

Confirm `guardrails.mdc` and `SESSION.md` are loaded.
If missing, ask user (pt-BR):

```text
Antes da localizacao, confirme:
- guardrails.mdc lido
- SESSION.md carregado

Posso seguir? (sim / ajustar / cancelar)
```

### -2. Caveman Mode Check

Check `~/.cursor/sdd/preferences.json`:
- If file missing -> create with `{ "caveman_mode": false }`.
- If `caveman_mode: true` -> load `~/.cursor/skills/_shared/caveman/CAVEMAN.md` and honor active compressions.

### 0. Frame the Context

* Identify the localization pattern used in the repository:
  * Dotnet: `.resx` resources with `IStringLocalizer<T>`.
  * React: `react-i18next` (`useTranslation()` hook, `t('key')`).
  * Angular: `@angular/core` i18n attributes or packages like `ngx-translate`/`transloco`.
* Confirm the primary language (usually English for resources) and target translation languages.

### 1. Scan for String Literals & Workflow Decision

* Read target files and identify raw text content in HTML tags or hardcoded string variables.
* **Filter out:**
  * Log templates (like warning logs).
  * System keys (like routing paths, config names, constants, and dictionary keys).
* Present a list of candidate strings with suggested keys (e.g. `WelcomeMessage`, `SubmitButtonLabel`).
* Stop and ask the user to choose the workflow execution path to refactor and localize these strings:
  * **Option A - Direct Developer Skill (`use skill developer`):** For straightforward local string extraction and key replacements.
  * **Option B - Classic SDD (`use skill sdd-spec` -> `sdd-plan` -> `sdd-develop`):** For massive application-wide localization tasks requiring formal specifications (PRD) and a detailed plan (PLAN) in Portuguese.
  * **Option C - Spec Kit (`use skill speckit-spec` -> `speckit-plan` -> `speckit-develop`):** For repositories initialized with Spec Kit.
  * **Option D - Plain Chat Plan:** Establish a simple task list directly in the chat, executing steps one by one without extra file creations.
* **Wait for explicit user choice** before writing code or initializing another workflow.

### 2. Update Resource Bundles

* Write or append the translations to the resource files:
  * JSON bundles: add key/value fields in `en.json`, `pt.json`, etc.
  * Dotnet XML: add `<data name="Key"><value>Text</value></data>` nodes in target `.resx` files.
* Ensure keys are sorted alphabetically to prevent duplicate entries and maintain layout.

### 3. Code Refactoring

* Replace the hardcoded string literal in the code file with the dynamic localization call.
* Inject the localizer dependency if it is not already available (e.g. adding `private readonly IStringLocalizer<T> _localizer` to C# constructor, or `const { t } = useTranslation()` in React component).

### 4. Build and Verify

* Run the project build script (`dotnet build`, `npm run build`) to ensure that imports, injections, and variables compile correctly.

### 5. Handoff

* Offer committing the refactored code and resources:

```
use skill commit
```

## Must not

* Extract string keys with generic names (like `Text1`, `String2`).
* Mutate logger strings or database connection configurations.
