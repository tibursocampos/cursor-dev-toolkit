#Requires -Version 5.1
<#
.SYNOPSIS
  Runs the cursor-dev-toolkit smoke test suite.

.DESCRIPTION
  Orchestrates deploy, structure, docs, and language validations. Optional
  Spec Kit and session-gate checks are available via flags.

.PARAMETER RepoPath
  Repository path for optional Spec Kit validation.

.PARAMETER IncludeSpeckit
  Run validate-speckit-init.ps1.

.PARAMETER IncludeSessionGate
  Run validate-session-gates.ps1.

.PARAMETER RequiredGate
  Gate name when IncludeSessionGate is enabled.

.PARAMETER FailFast
  Stop on first failing check.

.PARAMETER Quiet
  Suppress per-check banners; print summary only.

.EXAMPLE
  .\scripts\validation\validate-all.ps1

.EXAMPLE
  .\scripts\validation\validate-all.ps1 -IncludeSpeckit -RepoPath "D:\Source\Repos\MyApp"
#>
[CmdletBinding()]
param(
    [string] $RepoPath = (Get-Location).Path,
    [switch] $IncludeSpeckit,
    [switch] $IncludeSessionGate,
    [ValidateSet('storage_confirmed', 'write_confirmed', 'step_confirmed', 'tests_run')]
    [string] $RequiredGate = 'write_confirmed',
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
    if ($IncludeSpeckit) {
        $result = Invoke-ValidationCheck `
            -Name 'speckit-init' `
            -ScriptPath (Join-Path $scriptDir 'validate-speckit-init.ps1') `
            -Arguments @('-RepoPath', $RepoPath)
        $results += $result

        if ($FailFast -and $result.Status -eq 'FAIL') {
            # stop optional checks
        }
    }
    else {
        $results += [PSCustomObject]@{ Name = 'speckit-init'; Status = 'SKIP'; ExitCode = 0 }
    }
}

if (-not ($FailFast -and ($results | Where-Object { $_.Status -eq 'FAIL' }))) {
    if ($IncludeSessionGate) {
        $result = Invoke-ValidationCheck `
            -Name 'session-gate' `
            -ScriptPath (Join-Path $scriptDir 'validate-session-gates.ps1') `
            -Arguments @('-RepoPath', $RepoPath, '-RequiredGate', $RequiredGate)
        $results += $result
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
