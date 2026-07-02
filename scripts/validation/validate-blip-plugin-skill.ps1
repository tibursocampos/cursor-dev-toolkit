#Requires -Version 5.1
<#
.SYNOPSIS
  Validates blip-plugin-developer skill and blip-guidelines bundle.

.DESCRIPTION
  Called by validate-all.ps1. Checks SKILL.md structure, required guideline files,
  positive markers (create-blip-extension, config:plugin, handoffs), and forbidden Antigravity patterns.

.EXAMPLE
  .\scripts\validation\validate-blip-plugin-skill.ps1
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
$skillPath = Join-Path $RepoRoot 'skills\blip-plugin-developer\SKILL.md'
$guidelinesRoot = Join-Path $RepoRoot 'skills\_shared\blip-guidelines'

$requiredGuidelines = @(
    'plugin-architecture.md',
    'design-system.md',
    'blip-iframe-messages.md',
    'auth-and-permissions.md',
    'external-api-integration.md',
    'deploy-and-ci.md'
)

if (-not (Test-Path -LiteralPath $skillPath)) {
    Write-Host 'Blip plugin validation FAILED: skills/blip-plugin-developer/SKILL.md missing' -ForegroundColor Red
    exit 1
}

$content = Get-Content -LiteralPath $skillPath -Raw

if ($content.Length -lt 1500) {
    $failures += 'SKILL.md too small (likely incomplete)'
}

$requiredMarkers = @(
    'config:plugin',
    'create blip-extension',
    'react-developer',
    'sdd-spec',
    'speckit-spec',
    'impeccable shape',
    'blip-guidelines'
)
foreach ($m in $requiredMarkers) {
    if ($content -notmatch [regex]::Escape($m)) {
        $failures += "SKILL.md missing expected marker: $m"
    }
}

$forbiddenPatterns = @(
    @{ Pattern = 'impeccable_developer'; Message = 'Antigravity persona impeccable_developer' },
    @{ Pattern = 'dev_persona'; Message = 'Antigravity dev_persona reference' },
    @{ Pattern = 'NEW_PACKAGE_NAME'; Message = 'Wrong placeholder NEW_PACKAGE_NAME' },
    @{ Pattern = 'git clone https://github.com/takenet/cra-template-blip-plugin'; Message = 'Wrong microbundle template clone URL' },
    @{ Pattern = '\{pluginRoot\}/GUARDRAILS'; Message = 'Antigravity GUARDRAILS path' }
)
foreach ($item in $forbiddenPatterns) {
    if ($content -match $item.Pattern) {
        $failures += "SKILL.md contains forbidden pattern: $($item.Message)"
    }
}

foreach ($file in $requiredGuidelines) {
    $path = Join-Path $guidelinesRoot $file
    if (-not (Test-Path -LiteralPath $path)) {
        $failures += "Missing guideline: blip-guidelines/$file"
    }
    elseif ((Get-Item -LiteralPath $path).Length -lt 200) {
        $failures += "Guideline too small: blip-guidelines/$file"
    }
}

$integrationDoc = Join-Path $RepoRoot 'docs\blip-plugin-integration.md'
if (-not (Test-Path -LiteralPath $integrationDoc)) {
    $failures += 'Missing docs/blip-plugin-integration.md'
}

if ($failures.Count -gt 0) {
    Write-Host 'Blip plugin validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Blip plugin validation passed ($($requiredGuidelines.Count) guideline files)." -ForegroundColor Green
exit 0
