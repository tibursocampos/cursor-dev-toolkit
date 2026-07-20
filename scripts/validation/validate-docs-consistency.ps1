#Requires -Version 5.1
<#
.SYNOPSIS
  Checks docs for obsolete skill names, sibling toolkit refs, and GitHub CLI usage.

.DESCRIPTION
  Called by validate-all.ps1. Fails on legacy SDD/doc skill names.
  Expects canonical kebab-case: sdd-spec, sdd-plan, sdd-develop, developer, dotnet-developer,
  document-plan, document-implement. Forbids antigravity-dev-toolkit cross-refs and gh CLI.

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

$ghForbiddenRegex = @(
    '(?i)(?<![\w/`.])gh (pr|run|api|auth|repo)\b',
    '(?i)`gh`',
    '(?i)GitHub/`gh`',
    '(?i)GitHub CLI example',
    '(?i)optional GitHub Actions via gh',
    '(?i)via gh\b'
)

$siblingForbidden = @(
    'antigravity-dev-toolkit',
    'sync-antigravity'
)

$failures = @()

function Get-ToolkitMarkdownFiles {
    param([string] $Root)
    if (-not (Test-Path -LiteralPath $Root)) { return @() }
    return @(Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -eq '.md' } |
        ForEach-Object { $_.FullName })
}

$docFiles = @($readmePath, $agentsPath) + (Get-ToolkitMarkdownFiles -Root $docsRoot)
$skillFiles = Get-ToolkitMarkdownFiles -Root $skillsRoot
$scanFiles = @($docFiles + $skillFiles | Select-Object -Unique)

foreach ($file in $scanFiles) {
    if (-not (Test-Path -LiteralPath $file)) { continue }
    if ($file -like '*ENFORCEMENT.md*') { continue }
    $content = Get-Content -LiteralPath $file -Raw
    if ([string]::IsNullOrEmpty($content)) { continue }
    $rel = $file.Substring($RepoRoot.Length).TrimStart('\', '/')
    $isDocSurface = ($file -eq $readmePath) -or ($file -eq $agentsPath) -or ($file.StartsWith($docsRoot, [System.StringComparison]::OrdinalIgnoreCase))

    if ($isDocSurface) {
        foreach ($pattern in $obsoletePatterns) {
            if ($content -match $pattern) {
                $failures += "$rel : obsolete pattern '$pattern'"
            }
        }
    }

    foreach ($needle in $siblingForbidden) {
        if ($content.Contains($needle)) {
            $failures += "$rel : forbidden sibling/cross-toolkit reference '$needle'"
        }
    }

    foreach ($pattern in $ghForbiddenRegex) {
        if ($content -match $pattern) {
            $failures += "$rel : forbidden GitHub CLI pattern '$pattern'"
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

if (Test-Path -LiteralPath $readmePath) {
    $readme = Get-Content -LiteralPath $readmePath -Raw
    foreach ($dir in $skillDirs) {
        $name = $dir.Name
        if ($readme -notmatch [regex]::Escape("``$name``")) {
            $failures += "README.md missing Skills table entry for: $name"
        }
    }
}

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
