#Requires -Version 5.1
<#
.SYNOPSIS
  Fixes guardrails.mdcc regression and legacy sdd skill display names (ASCII-safe).
#>
[CmdletBinding()]
param([string] $RepoRoot)

if (-not $RepoRoot) {
    . (Join-Path (Split-Path -Parent $PSScriptRoot) '_lib\Get-ToolkitRepoRoot.ps1')
    $RepoRoot = Get-ToolkitRepoRoot -FromPath $PSScriptRoot
}

$replacements = [ordered]@{
    'guardrails.mdcc' = 'guardrails.mdc'
    'SDD sdd-develop' = 'SDD develop (`sdd-develop`)'
    'Mirror SDD sdd-develop updates' = 'Mirror `sdd-develop` PLAN-style updates'
    '`spec` / `plan`' = '`sdd-spec` / `sdd-plan`'
    '`spec`, `plan`' = '`sdd-spec`, `sdd-plan`'
    'Apply to: `spec`, `plan`' = 'Apply to: `sdd-spec`, `sdd-plan`'
    'hand off to `spec`' = 'hand off to `sdd-spec`'
    'Redirect to `spec` / `plan`' = 'Redirect to `sdd-spec` / `sdd-plan`'
    'hand off to `spec` / `plan`' = 'hand off to `sdd-spec` / `sdd-plan`'
    'applied by `spec` / `plan`' = 'applied by `sdd-spec` / `sdd-plan`'
    '| `spec` / `plan` |' = '| `sdd-spec` / `sdd-plan` |'
    '`spec` / `plan` / `sdd-develop`' = '`sdd-spec` / `sdd-plan` / `sdd-develop`'
    'prefer spec -> plan -> implement' = 'prefer sdd-spec -> sdd-plan -> sdd-develop'
    'spec -> plan -> implement' = 'sdd-spec -> sdd-plan -> sdd-develop'
    'spec -> plan -> sdd-develop' = 'sdd-spec -> sdd-plan -> sdd-develop'
    '`spec` -> `plan` -> `sdd-develop`' = '`sdd-spec` -> `sdd-plan` -> `sdd-develop`'
    'use `spec`, `plan`, `sdd-develop`' = 'use `sdd-spec`, `sdd-plan`, `sdd-develop`'
    '-> `plan` ->' = '-> `sdd-plan` ->'
    '-> `plan`' = '-> `sdd-plan`'
    '`plan` -> `sdd-develop`' = '`sdd-plan` -> `sdd-develop`'
    'Doc-update steps: **implement** asks' = 'Doc-update steps: **sdd-develop** asks'
    'implement steps' = 'sdd-develop steps'
    'New session -> `implement' = 'New session -> `use skill sdd-develop'
    '**LITE**: `spec`, `plan`' = '**LITE**: `sdd-spec`, `sdd-plan`'
    'Apply to `spec`, `plan`' = 'Apply to `sdd-spec`, `sdd-plan`'
    'Skill names | English, kebab-case (`spec`, `plan`' = 'Skill names | English, kebab-case (`sdd-spec`, `sdd-plan`'
    'PRD/`spec` or PLAN/`plan`' = 'PRD/`sdd-spec` or PLAN/`sdd-plan`'
    '# plan-repo-docs - reference' = '# document-plan - reference'
    '# document-repo - reference' = '# document-implement - reference'
    'created by `plan-repo-docs`' = 'created by `document-plan`'
    '| `spec`, `plan`, `sdd-develop`' = '| `sdd-spec`, `sdd-plan`, `sdd-develop`'
    'LITE** | `spec`, `plan`' = 'LITE** | `sdd-spec`, `sdd-plan`'
    'use `spec` / `plan` / `sdd-develop`' = 'use `sdd-spec` / `sdd-plan` / `sdd-develop`'
    'skills `spec` / `plan`' = 'skills `sdd-spec` / `sdd-plan`'
    '-> `plan` -> `sdd-develop`' = '-> `sdd-plan` -> `sdd-develop`'
    'Recommend `use skill sdd-spec` -> `plan` -> `sdd-develop`' = 'Recommend `use skill sdd-spec` -> `sdd-plan` -> `sdd-develop`'
    'use `spec`, `plan`, `sdd-develop`, `commit` only' = 'use `sdd-spec`, `sdd-plan`, `sdd-develop`, `commit` only'
    'Large scope | `use skill sdd-spec` -> `plan` -> `sdd-develop`' = 'Large scope | `use skill sdd-spec` -> `sdd-plan` -> `sdd-develop`'
    'Choice **1** -> hand off to `spec` inputs' = 'Choice **1** -> hand off to `sdd-spec` inputs'
    '-> `plan` -> `sdd-develop` if' = '-> `sdd-plan` -> `sdd-develop` if'
    '-> `plan` -> hand off' = '-> `sdd-plan` -> hand off'
    'Large feature scope | `use skill sdd-spec` -> `plan` -> `sdd-develop`' = 'Large feature scope | `use skill sdd-spec` -> `sdd-plan` -> `sdd-develop`'
}

$exclude = @('fix-encoding-and-skill-names.ps1', 'fix-legacy-display-names.ps1')
$files = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Include '*.md','*.mdc' |
    Where-Object { $_.FullName -notmatch '\\\.git\\' -and ($exclude -notcontains $_.Name) }

foreach ($file in $files) {
    $original = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $updated = $original
    foreach ($pair in $replacements.GetEnumerator()) {
        $updated = $updated.Replace($pair.Key, $pair.Value)
    }
    if ($updated -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
        Write-Host "Fixed: $($file.Name)"
    }
}

Write-Host 'Done.'
