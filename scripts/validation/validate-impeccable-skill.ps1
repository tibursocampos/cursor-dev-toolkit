#Requires -Version 5.1
<#
.SYNOPSIS
  Validates impeccable skill router and minimum reference bundle.

.DESCRIPTION
  Called by validate-all.ps1. Checks SKILL.md structure and required reference files
  vendored from pbakaus/impeccable.

.EXAMPLE
  .\scripts\validation\validate-impeccable-skill.ps1
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
$skillPath = Join-Path $RepoRoot 'skills\impeccable\SKILL.md'
$refRoot = Join-Path $RepoRoot 'skills\impeccable\reference'

$requiredRefs = @(
    'init.md', 'shape.md', 'craft.md', 'audit.md', 'polish.md', 'critique.md',
    'harden.md', 'onboard.md', 'interaction-design.md', 'brand.md', 'product.md',
    'DESIGN-BRIEF-TEMPLATE.md'
)

if (-not (Test-Path -LiteralPath $skillPath)) {
    Write-Host 'Impeccable validation FAILED: skills/impeccable/SKILL.md missing' -ForegroundColor Red
    exit 1
}

$content = Get-Content -LiteralPath $skillPath -Raw

$markers = @(
    'npx impeccable detect',
    'DESIGN-BRIEF',
    'reference/<command>.md',
    'npx impeccable install'
)
foreach ($m in $markers) {
    if ($content -notmatch [regex]::Escape($m)) {
        $failures += "SKILL.md missing expected marker: $m"
    }
}

foreach ($ref in $requiredRefs) {
    $path = Join-Path $refRoot $ref
    if (-not (Test-Path -LiteralPath $path)) {
        $failures += "Missing reference: reference/$ref"
    }
    elseif ((Get-Item -LiteralPath $path).Length -lt 200) {
        $failures += "Reference too small (likely empty): reference/$ref"
    }
}

$refCount = @(Get-ChildItem -LiteralPath $refRoot -Filter '*.md' -ErrorAction SilentlyContinue).Count
if ($refCount -lt 10) {
    $failures += "Expected at least 10 reference/*.md files (found $refCount)"
}

if ($failures.Count -gt 0) {
    Write-Host 'Impeccable validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Impeccable validation passed ($refCount reference files)." -ForegroundColor Green
exit 0
