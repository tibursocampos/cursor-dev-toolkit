#Requires -Version 5.1
<#
.SYNOPSIS
  Prepends gate-first STOP block to SKILL.md files that lack it.
#>
[CmdletBinding()]
param(
    [string] $SkillsRoot
)

if (-not $SkillsRoot) {
    . (Join-Path (Split-Path -Parent $PSScriptRoot) '_lib\Get-ToolkitRepoRoot.ps1')
    $repoRoot = Get-ToolkitRepoRoot -FromPath $PSScriptRoot
    $SkillsRoot = Join-Path $repoRoot 'skills'
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$gateBlock = @'

## STOP - Read before ANY tool call

1. Read `~/.cursor/rules/guardrails.mdc`
2. Read `_shared/sdd-artifacts/SESSION.md`; load session-state for `$Cwd`
3. If the relevant gate is not approved: **STOP** - ask user **(pt-BR)** - do **NOT** Write/Shell
4. SDD/develop skills: after **ONE** step/task, **STOP** session - handoff only
5. This skill body is **English**; user-facing prompts may be **(pt-BR)**

### Step -1 - Gate check (report in chat before continuing)

```
Gate check:
[ ] guardrails.mdc read
[ ] SESSION.md read; session-state loaded
[ ] PIPELINE.md read (SDD skills only)
[ ] User confirmed current action (sim)
-> If any unchecked: STOP
```

---

'@

Get-ChildItem -LiteralPath $SkillsRoot -Recurse -Filter 'SKILL.md' | ForEach-Object {
    $content = Get-Content -LiteralPath $_.FullName -Raw
    if ($content -match '## STOP - Read before ANY tool call') {
        Write-Host "Skip (already has gate): $($_.FullName)"
        return
    }

    if ($content -notmatch '(?s)^---\r?\n.*?\r?\n---\r?\n') {
        Write-Warning "No frontmatter: $($_.FullName)"
        return
    }

    $updated = [regex]::Replace($content, '(?s)^(---\r?\n.*?\r?\n---\r?\n)', "`$1$gateBlock", 1)
    [System.IO.File]::WriteAllText($_.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Injected gate: $($_.FullName)"
}
