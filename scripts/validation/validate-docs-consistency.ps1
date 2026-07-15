#Requires -Version 5.1
<#
.SYNOPSIS
  Checks docs for obsolete skill names and orphan skill references.

.DESCRIPTION
  Called by validate-all.ps1. Fails on legacy SDD/doc skill names.
  Expects canonical kebab-case: sdd-spec, sdd-plan, sdd-develop, developer, dotnet-developer,
  document-plan, document-implement.

.EXAMPLE
  .\scripts\validation\validate-docs-consistency.ps1
#>
[CmdletBinding()]
param(
    [string] $RepoRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    . (Join-Path (Split-Path -Parent $PSScriptRoot) '_lib\Get-ToolkitRepoRoot.ps1')
    $RepoRoot = Get-ToolkitRepoRoot -FromPath $PSScriptRoot
}

$docsRoot = Join-Path $RepoRoot 'docs'
$skillsRoot = Join-Path $RepoRoot 'skills'
$readmePath = Join-Path $RepoRoot 'README.md'
$agentsPath = Join-Path $RepoRoot 'AGENTS.md'

$obsoletePatterns = @(
    'use skill implement\b',
    'use skill plan-repo-docs\b',
    'use skill document-repo\b',
    '/implement\b',
    '/plan-repo-docs\b',
    '/document-repo\b',
    'skills/spec/',
    'skills/plan/',
    'skills/implement/',
    'skills/plan-repo-docs/',
    'skills/document-repo/',
    'name: implement\b',
    'name: spec\b',
    'name: plan\b',
    '\| `spec` \|',
    '\| `plan` \|',
    'dev_persona always active',
    'loaded automatically',
    'dotnet_developer',
    'react_developer',
    'angular_developer',
    'javascript_developer',
    'python_developer'
)

$failures = @()
$files = @($readmePath, $agentsPath) + (Get-ChildItem -LiteralPath $docsRoot -Recurse -Filter '*.md' -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })

foreach ($file in $files) {
    if (-not (Test-Path -LiteralPath $file)) { continue }
    if ($file -like '*ENFORCEMENT.md*') { continue }
    if ($file -like '*SYNC_POLICY.md*') { continue }
    $content = Get-Content -LiteralPath $file -Raw
    foreach ($pattern in $obsoletePatterns) {
        if ($content -match $pattern) {
            $rel = $file.Substring($RepoRoot.Length).TrimStart('\', '/')
            $failures += "$rel : obsolete pattern '$pattern'"
        }
    }
}

$skillDirs = Get-ChildItem -LiteralPath $skillsRoot -Directory | Where-Object { $_.Name -ne '_shared' }
$skillsMd = Join-Path $docsRoot 'SKILLS.md'
if (Test-Path -LiteralPath $skillsMd) {
    $catalog = Get-Content -LiteralPath $skillsMd -Raw
    foreach ($dir in $skillDirs) {
        $name = $dir.Name
        if ($catalog -notmatch [regex]::Escape($name)) {
            $failures += "SKILLS.md missing catalog entry for: $name"
        }
    }
}
else {
    $failures += 'docs/SKILLS.md missing (required catalog)'
}

# README Skills table must list every skill folder (CI parity with pastas)
if (Test-Path -LiteralPath $readmePath) {
    $readme = Get-Content -LiteralPath $readmePath -Raw
    foreach ($dir in $skillDirs) {
        $name = $dir.Name
        if ($readme -notmatch [regex]::Escape("``$name``")) {
            $failures += "README.md missing Skills table entry for: $name"
        }
    }
}

# Anti-regression: Forma A guide must teach features/ storage
$guide01 = Join-Path $docsRoot 'guides\01-sdd-workflow.md'
if (-not (Test-Path -LiteralPath $guide01)) {
    $failures += 'docs/guides/01-sdd-workflow.md missing'
}
else {
    $guide01Content = Get-Content -LiteralPath $guide01 -Raw
    if ($guide01Content -notmatch 'features/') {
        $failures += 'docs/guides/01-sdd-workflow.md must mention features/ (canonical Classic SDD storage)'
    }
}

# Anti-regression: O3 must not advertise silent multi-angle opt-in
$o3Skill = Join-Path $skillsRoot 'orchestrate-develop\SKILL.md'
if (Test-Path -LiteralPath $o3Skill) {
    $o3Head = (Get-Content -LiteralPath $o3Skill -TotalCount 5) -join "`n"
    if ($o3Head -match 'multi-angle opt-in') {
        $failures += 'skills/orchestrate-develop/SKILL.md description must not say multi-angle opt-in (ask mode)'
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Docs consistency validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'Docs consistency validation passed.' -ForegroundColor Green
exit 0
