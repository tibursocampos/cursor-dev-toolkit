#Requires -Version 5.1
<#
.SYNOPSIS
  Validates cursor-dev-toolkit deployment under ~/.cursor/.

.DESCRIPTION
  Called by validate-all.ps1. Checks AGENTS.md, guardrails rule, SESSION.md,
  hooks/, and the SDD sessions directory. Does not validate Antigravity-style KIs.

.EXAMPLE
  .\scripts\validate-toolkit-deploy.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$repoRoot = Split-Path -Parent $scriptDir
$cursorRoot = Join-Path $env:USERPROFILE '.cursor'

$checks = @(
    @{ Path = Join-Path $cursorRoot 'AGENTS.md'; Label = 'AGENTS.md in ~/.cursor' },
    @{ Path = Join-Path $cursorRoot 'rules\guardrails.mdc'; Label = 'rules/guardrails.mdc deployed' },
    @{ Path = Join-Path $cursorRoot 'skills\_shared\sdd-artifacts\SESSION.md'; Label = 'SESSION.md in ~/.cursor/skills' },
    @{ Path = Join-Path $cursorRoot 'hooks'; Label = 'hooks/ directory' },
    @{ Path = Join-Path $cursorRoot 'sdd\sessions'; Label = 'sdd/sessions directory' }
)

$failed = $false
foreach ($check in $checks) {
    if (Test-Path -LiteralPath $check.Path) {
        Write-Host "[OK] $($check.Label)" -ForegroundColor Green
    }
    else {
        Write-Host "[MISSING] $($check.Label) - $($check.Path)" -ForegroundColor Red
        $failed = $true
    }
}

$skillCount = (Get-ChildItem -LiteralPath (Join-Path $repoRoot 'skills') -Directory |
    Where-Object { $_.Name -ne '_shared' }).Count
Write-Host "Skills in repo: $skillCount"

if ($failed) {
    Write-Host 'Deploy validation FAILED. Run: .\scripts\sync-cursor.ps1' -ForegroundColor Red
    exit 1
}

Write-Host 'Deploy validation passed.' -ForegroundColor Green
exit 0
