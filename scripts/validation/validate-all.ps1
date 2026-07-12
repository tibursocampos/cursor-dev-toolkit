#Requires -Version 5.1
<#
.SYNOPSIS
  Runs the cursor-dev-toolkit smoke test suite.

.DESCRIPTION
  Orchestrates deploy, structure, docs, and language validations. Optional
  session-gate checks are available via flags.

.PARAMETER RepoPath
  Repository path for optional session-gate validation.

.PARAMETER IncludeSessionGate
  Run validate-session-gates.ps1.

.PARAMETER RequiredGate
  Gate name when IncludeSessionGate is enabled.
  Default write_confirmed (repo session). Develop gates require -PlanPath.

.PARAMETER PlanPath
  Forwarded to validate-session-gates.ps1. Required when RequiredGate is
  step_confirmed or tests_run.

.PARAMETER Step
  Forwarded for PLAN+step develop sessions (0 = no step scope).

.PARAMETER FailFast
  Stop on first failing check.

.PARAMETER Quiet
  Suppress per-check banners; print summary only.

.EXAMPLE
  .\scripts\validation\validate-all.ps1

.EXAMPLE
  .\scripts\validation\validate-all.ps1 -IncludeSessionGate -RequiredGate step_confirmed -PlanPath "D:\...\PLAN_004_x.md"
#>
[CmdletBinding()]
param(
    [string] $RepoPath = (Get-Location).Path,
    [switch] $IncludeSessionGate,
    [ValidateSet('storage_confirmed', 'write_confirmed', 'step_confirmed', 'tests_run')]
    [string] $RequiredGate = 'write_confirmed',
    [string] $PlanPath,
    [int] $Step = 0,
    [switch] $FailFast,
    [switch] $Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

function Write-Banner([string] $Message) {
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor Cyan
    }
}

function Invoke-ValidationCheck {
    param(
        [string] $Name,
        [string] $ScriptPath,
        [string[]] $Arguments = @()
    )

    Write-Banner "Running: $Name"
    & $ScriptPath @Arguments
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) {
        $exitCode = 0
    }

    return [PSCustomObject]@{
        Name     = $Name
        Status   = if ($exitCode -eq 0) { 'PASS' } else { 'FAIL' }
        ExitCode = $exitCode
    }
}

if (-not $Quiet) {
    Write-Host ''
    Write-Host 'cursor-dev-toolkit smoke test' -ForegroundColor Cyan
    Write-Host '=============================' -ForegroundColor Cyan
    Write-Host ''
}

$results = @()

$coreChecks = @(
    @{ Name = 'deploy'; Script = 'validate-toolkit-deploy.ps1'; Args = @() },
    @{ Name = 'skills-structure'; Script = 'validate-skills-structure.ps1'; Args = @() },
    @{ Name = 'impeccable-skill'; Script = 'validate-impeccable-skill.ps1'; Args = @() },
    @{ Name = 'blip-plugin-skill'; Script = 'validate-blip-plugin-skill.ps1'; Args = @() },
    @{ Name = 'frontend-ecosystem'; Script = 'validate-frontend-ecosystem.ps1'; Args = @() },
    @{ Name = 'docs-consistency'; Script = 'validate-docs-consistency.ps1'; Args = @() },
    @{ Name = 'skills-english'; Script = 'validate-skills-english.ps1'; Args = @() }
)

foreach ($check in $coreChecks) {
    $result = Invoke-ValidationCheck -Name $check.Name -ScriptPath (Join-Path $scriptDir $check.Script) -Arguments $check.Args
    $results += $result

    if ($FailFast -and $result.Status -eq 'FAIL') {
        break
    }
}

if (-not ($FailFast -and ($results | Where-Object { $_.Status -eq 'FAIL' }))) {
    if ($IncludeSessionGate) {
        $developGates = @('step_confirmed', 'tests_run')
        if (($RequiredGate -in $developGates) -and [string]::IsNullOrWhiteSpace($PlanPath)) {
            Write-Host "IncludeSessionGate with develop gate '$RequiredGate' requires -PlanPath. Use write_confirmed/storage_confirmed without PlanPath, or pass -PlanPath for develop gates." -ForegroundColor Red
            $results += [PSCustomObject]@{ Name = 'session-gate'; Status = 'FAIL'; ExitCode = 1 }
        }
        else {
            $gateArgs = @('-RepoPath', $RepoPath, '-RequiredGate', $RequiredGate)
            if (-not [string]::IsNullOrWhiteSpace($PlanPath)) {
                $gateArgs += @('-PlanPath', $PlanPath)
            }
            if ($Step -gt 0) {
                $gateArgs += @('-Step', "$Step")
            }
            $result = Invoke-ValidationCheck `
                -Name 'session-gate' `
                -ScriptPath (Join-Path $scriptDir 'validate-session-gates.ps1') `
                -Arguments $gateArgs
            $results += $result
        }
    }
    else {
        $results += [PSCustomObject]@{ Name = 'session-gate'; Status = 'SKIP'; ExitCode = 0 }
    }
}

Write-Host ''
Write-Host 'Smoke test summary' -ForegroundColor Cyan
Write-Host '----------------' -ForegroundColor Cyan
foreach ($result in $results) {
    $color = switch ($result.Status) {
        'PASS' { [ConsoleColor]::Green }
        'FAIL' { [ConsoleColor]::Red }
        'SKIP' { [ConsoleColor]::DarkGray }
        default { [ConsoleColor]::Gray }
    }
    Write-Host ("{0,-20} {1}" -f $result.Name, $result.Status) -ForegroundColor $color
}

$failed = @($results | Where-Object { $_.Status -eq 'FAIL' })
if ($failed.Count -gt 0) {
    Write-Host ''
    Write-Host "Smoke test FAILED ($($failed.Count) check(s))." -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host 'Smoke test PASSED.' -ForegroundColor Green
exit 0
