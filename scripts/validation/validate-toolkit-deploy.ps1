#Requires -Version 5.1
<#
.SYNOPSIS
  Validates cursor-dev-toolkit deployment under ~/.cursor/.

.DESCRIPTION
  Called by validate-all.ps1. Checks AGENTS.md, all rules, SESSION.md,
  hooks/ (including script paths in hooks.json), and the SDD sessions directory.

.EXAMPLE
  .\scripts\validation\validate-toolkit-deploy.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path -Parent $PSScriptRoot) '_lib\Get-ToolkitRepoRoot.ps1')
$repoRoot = Get-ToolkitRepoRoot -FromPath $PSScriptRoot
$cursorRoot = Join-Path $env:USERPROFILE '.cursor'

$requiredRules = @(
    'guardrails.mdc',
    'ai-stealth.mdc',
    'sdd-pipeline-guards.mdc',
    'branch-validation.mdc',
    'conventional-commits.mdc',
    'context-management.mdc',
    'user-language-pt-br.mdc',
    'sdd-artifact-language-pt-br.mdc',
    'caveman-mode.mdc'
)

$checks = @(
    @{ Path = Join-Path $cursorRoot 'AGENTS.md'; Label = 'AGENTS.md in ~/.cursor' },
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

foreach ($ruleName in $requiredRules) {
    $rulePath = Join-Path $cursorRoot "rules\$ruleName"
    if (Test-Path -LiteralPath $rulePath) {
        Write-Host "[OK] rules/$ruleName deployed" -ForegroundColor Green
    }
    else {
        Write-Host "[MISSING] rules/$ruleName - $rulePath" -ForegroundColor Red
        $failed = $true
    }
}

$hooksJsonPath = Join-Path $repoRoot 'hooks\hooks.json'
if (Test-Path -LiteralPath $hooksJsonPath) {
    $hooksConfig = Get-Content -LiteralPath $hooksJsonPath -Raw | ConvertFrom-Json
    $hookEvents = @('beforeSubmitPrompt', 'afterFileEdit', 'preCompact')
    foreach ($eventName in $hookEvents) {
        $eventHooks = $hooksConfig.hooks.$eventName
        if (-not $eventHooks) { continue }
        foreach ($hook in $eventHooks) {
            if ($hook.command -match '\./hooks/([^\s"]+\.ps1)') {
                $scriptName = $Matches[1]
                $scriptPath = Join-Path $repoRoot "hooks\$scriptName"
                if (Test-Path -LiteralPath $scriptPath) {
                    Write-Host "[OK] hooks.json -> $scriptName exists" -ForegroundColor Green
                }
                else {
                    Write-Host "[MISSING] hooks.json references $scriptName but file not found" -ForegroundColor Red
                    $failed = $true
                }
            }
        }
    }
}
else {
    Write-Host "[MISSING] hooks/hooks.json in repo" -ForegroundColor Red
    $failed = $true
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
