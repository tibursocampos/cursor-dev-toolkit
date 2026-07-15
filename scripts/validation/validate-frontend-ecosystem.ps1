#Requires -Version 5.1
<#
.SYNOPSIS
  Validates frontend ecosystem skills, guidelines, and Impeccable alignment.

.DESCRIPTION
  Called by validate-all.ps1. Checks new stack skills exist, guideline bundles are present,
  frontend-practices.md has no Impeccable-conflicting markers, and stack skills reference DESIGN-BRIEF.

.EXAMPLE
  .\scripts\validation\validate-frontend-ecosystem.ps1
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

$failures = @()
$skillsRoot = Join-Path $RepoRoot 'skills'
$sharedRoot = Join-Path $skillsRoot '_shared'

$newStackSkills = @('vue-developer', 'blazor-developer', 'electron-developer', 'blip-plugin-developer')
foreach ($skill in $newStackSkills) {
    $skillPath = Join-Path $skillsRoot "$skill\SKILL.md"
    if (-not (Test-Path -LiteralPath $skillPath)) {
        $failures += "Missing skill: skills/$skill/SKILL.md"
    }
    elseif ((Get-Item -LiteralPath $skillPath).Length -lt 500) {
        $failures += "Skill too small: skills/$skill/SKILL.md"
    }
}

$guidelineSets = @{
    'html-css-guidelines' = @('semantic-html.md', 'css-foundations.md', 'scss-guidelines.md')
    'vue-guidelines'      = @('vue-composition.md', 'vue-routing-state.md', 'vue-testing.md')
    'blazor-guidelines'   = @('blazor-components.md', 'blazor-state.md', 'blazor-testing.md')
    'electron-guidelines' = @('electron-main-renderer.md', 'electron-security.md', 'electron-packaging.md')
    'blip-guidelines'     = @('plugin-architecture.md', 'design-system.md', 'blip-iframe-messages.md', 'auth-and-permissions.md', 'external-api-integration.md', 'deploy-and-ci.md')
}

foreach ($folder in $guidelineSets.Keys) {
    $dir = Join-Path $sharedRoot $folder
    if (-not (Test-Path -LiteralPath $dir)) {
        $failures += "Missing guidelines folder: skills/_shared/$folder/"
        continue
    }
    foreach ($file in $guidelineSets[$folder]) {
        $path = Join-Path $dir $file
        if (-not (Test-Path -LiteralPath $path)) {
            $failures += "Missing guideline: skills/_shared/$folder/$file"
        }
        elseif ((Get-Item -LiteralPath $path).Length -lt 200) {
            $failures += "Guideline too small: skills/_shared/$folder/$file"
        }
    }
}

$jsGuidelines = @('typescript-strict.md', 'dom-patterns.md')
foreach ($file in $jsGuidelines) {
    $path = Join-Path $sharedRoot "javascript-guidelines\$file"
    if (-not (Test-Path -LiteralPath $path)) {
        $failures += "Missing guideline: skills/_shared/javascript-guidelines/$file"
    }
}

$feTesting = Join-Path $sharedRoot 'frontend-guidelines\frontend-testing.md'
if (-not (Test-Path -LiteralPath $feTesting)) {
    $failures += 'Missing: skills/_shared/frontend-guidelines/frontend-testing.md'
}

$reactPerf = Join-Path $sharedRoot 'react-guidelines\react-performance.md'
if (-not (Test-Path -LiteralPath $reactPerf)) {
    $failures += 'Missing: skills/_shared/react-guidelines/react-performance.md'
}

$frontendPractices = Join-Path $sharedRoot 'frontend-guidelines\frontend-practices.md'
if (-not (Test-Path -LiteralPath $frontendPractices)) {
    $failures += 'Missing: skills/_shared/frontend-guidelines/frontend-practices.md'
}
else {
    $fpContent = Get-Content -LiteralPath $frontendPractices -Raw
    $forbiddenMarkers = @('glassmorphism', 'Use web fonts (like Inter')
    foreach ($marker in $forbiddenMarkers) {
        if ($fpContent -match [regex]::Escape($marker)) {
            $failures += "frontend-practices.md contains forbidden marker: $marker"
        }
    }
    if ($fpContent -notmatch 'DESIGN-BRIEF') {
        $failures += 'frontend-practices.md should reference DESIGN-BRIEF'
    }
}

$stackSkillsWithBrief = @(
    'react-developer', 'react-native-developer', 'angular-developer', 'javascript-developer',
    'vue-developer', 'blazor-developer', 'electron-developer', 'blip-plugin-developer'
)
foreach ($skill in $stackSkillsWithBrief) {
    $skillPath = Join-Path $skillsRoot "$skill\SKILL.md"
    if (Test-Path -LiteralPath $skillPath) {
        $content = Get-Content -LiteralPath $skillPath -Raw
        if ($content -notmatch 'DESIGN-BRIEF') {
            $failures += "skills/$skill/SKILL.md missing DESIGN-BRIEF marker"
        }
    }
}

$developerPath = Join-Path $skillsRoot 'developer\SKILL.md'
if (Test-Path -LiteralPath $developerPath) {
    $devContent = Get-Content -LiteralPath $developerPath -Raw
    foreach ($skill in @('vue-developer', 'blazor-developer', 'electron-developer', 'blip-plugin-developer', 'react-native-developer')) {
        if ($devContent -notmatch [regex]::Escape($skill)) {
            $failures += "developer/SKILL.md missing router entry for: $skill"
        }
    }
}

$impeccablePath = Join-Path $skillsRoot 'impeccable\SKILL.md'
if (Test-Path -LiteralPath $impeccablePath) {
    $impContent = Get-Content -LiteralPath $impeccablePath -Raw
    foreach ($skill in @('vue-developer', 'blazor-developer', 'electron-developer', 'react-native-developer')) {
        if ($impContent -notmatch [regex]::Escape($skill)) {
            $failures += "impeccable/SKILL.md missing handoff for: $skill"
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Frontend ecosystem validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'Frontend ecosystem validation passed.' -ForegroundColor Green
exit 0
