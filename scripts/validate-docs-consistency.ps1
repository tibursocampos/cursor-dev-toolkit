#Requires -Version 5.1
<#
.SYNOPSIS
  Checks docs for obsolete skill names and orphan skill references.

.DESCRIPTION
  Called by validate-all.ps1. Fails on legacy SDD/doc skill names.
  Expects canonical kebab-case: sdd-spec, sdd-plan, sdd-develop, developer,
  document-plan, document-implement.

.EXAMPLE
  .\scripts\validate-docs-consistency.ps1
#>
[CmdletBinding()]
param(
    [string] $RepoRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    $scriptDir = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptDir)) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    $RepoRoot = Split-Path -Parent $scriptDir
}

$docsRoot = Join-Path $RepoRoot 'docs'
$skillsRoot = Join-Path $RepoRoot 'skills'
$readmePath = Join-Path $RepoRoot 'README.md'
$agentsPath = Join-Path $RepoRoot 'AGENTS.md'

$obsoletePatterns = @(
    'use skill implement\b',
    'use skill dotnet-developer\b',
    'use skill plan-repo-docs\b',
    'use skill document-repo\b',
    '/implement\b',
    '/dotnet-developer\b',
    '/plan-repo-docs\b',
    '/document-repo\b',
    'skills/spec/',
    'skills/plan/',
    'skills/implement/',
    'skills/dotnet-developer/',
    'skills/plan-repo-docs/',
    'skills/document-repo/',
    'name: implement\b',
    'name: dotnet-developer\b',
    'name: spec\b',
    'name: plan\b',
    '\| `spec` \|',
    '\| `plan` \|',
    'skills/spec/',
    'skills/plan/',
    'skills/implement/',
    'dev_persona always active',
    'loaded automatically'
)

$failures = @()
$files = @($readmePath, $agentsPath) + (Get-ChildItem -LiteralPath $docsRoot -Recurse -Filter '*.md' -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })

foreach ($file in $files) {
    if (-not (Test-Path -LiteralPath $file)) { continue }
    if ($file -like '*ENFORCEMENT.md*') { continue }
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

if ($failures.Count -gt 0) {
    Write-Host 'Docs consistency validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'Docs consistency validation passed.' -ForegroundColor Green
exit 0
