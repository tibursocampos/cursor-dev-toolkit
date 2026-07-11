#Requires -Version 5.1
<#
.SYNOPSIS
  Validates session gates for the active repository (and optional PLAN-scoped develop session).

.DESCRIPTION
  Called by validate-all.ps1 when -IncludeSessionGate is set.
  Repo gates (storage_confirmed, write_confirmed) use sessions\{repo-hash}.json.
  Develop gates (step_confirmed, tests_run) use sessions\{repo-hash}\plan-{plan-hash}.json
  (or plan-{plan-hash}-step-{N}.json when -Step is set). See SESSION.md.

.PARAMETER RepoPath
  Workspace path (defaults to current location).

.PARAMETER RequiredGate
  Gate name: storage_confirmed, write_confirmed, step_confirmed, tests_run

.PARAMETER PlanPath
  Full PLAN (or Spec Kit tasks.md) path. Required for step_confirmed / tests_run
  when using scoped develop sessions. Optional for repo gates.

.PARAMETER Step
  PLAN step number for parallel same-PLAN develop sessions (PLAN+step file).

.EXAMPLE
  .\scripts\validation\validate-session-gates.ps1 -RepoPath "D:\Source\Repos\MyApp" -RequiredGate write_confirmed

.EXAMPLE
  .\scripts\validation\validate-session-gates.ps1 -RepoPath "D:\Source\Repos\MyApp" -PlanPath "D:\Source\Repos\MyApp\features\004-x\US01\PLAN\PLAN_004_x.md" -RequiredGate step_confirmed
#>
[CmdletBinding()]
param(
    [string] $RepoPath = (Get-Location).Path,
    [Parameter(Mandatory = $true)]
    [ValidateSet('storage_confirmed', 'write_confirmed', 'step_confirmed', 'tests_run')]
    [string] $RequiredGate,
    [string] $PlanPath,
    [int] $Step = 0
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-PathHash([string] $Path) {
    $normalized = $Path.Replace('\', '/').TrimEnd('/')
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($normalized)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    $hex = [BitConverter]::ToString($hash).Replace('-', '').ToLowerInvariant()
    return $hex.Substring(0, 16)
}

function Get-DevelopSessionPath {
    param(
        [string] $SessionsDir,
        [string] $RepoHash,
        [string] $PlanPathNormalized,
        [int] $StepNumber
    )

    $planHash = Get-PathHash $PlanPathNormalized
    $repoDir = Join-Path $SessionsDir $RepoHash
    if ($StepNumber -gt 0) {
        return Join-Path $repoDir ("plan-{0}-step-{1}.json" -f $planHash, $StepNumber)
    }
    return Join-Path $repoDir ("plan-{0}.json" -f $planHash)
}

$sessionsDir = Join-Path $env:USERPROFILE '.cursor\sdd\sessions'
$repoHash = Get-PathHash $RepoPath
$repoSessionPath = Join-Path $sessionsDir "$repoHash.json"

$developGates = @('step_confirmed', 'tests_run')
$isDevelopGate = $RequiredGate -in $developGates

$sessionPath = $repoSessionPath
if ($isDevelopGate) {
    if ([string]::IsNullOrWhiteSpace($PlanPath)) {
        # Compat: fall back to legacy flat repo session if PlanPath omitted
        $sessionPath = $repoSessionPath
    }
    else {
        $planNorm = $PlanPath.Replace('\', '/').TrimEnd('/')
        $sessionPath = Get-DevelopSessionPath -SessionsDir $sessionsDir -RepoHash $repoHash -PlanPathNormalized $planNorm -StepNumber $Step

        if (-not (Test-Path -LiteralPath $sessionPath) -and (Test-Path -LiteralPath $repoSessionPath)) {
            # Allow reading legacy flat file when scoped file not yet migrated
            $sessionPath = $repoSessionPath
        }
    }
}

if (-not (Test-Path -LiteralPath $sessionPath)) {
    Write-Error "Session file not found: $sessionPath. Gate '$RequiredGate' is not approved."
    exit 1
}

$session = Get-Content -LiteralPath $sessionPath -Raw | ConvertFrom-Json
if (-not $session.gates -or -not ($session.gates.PSObject.Properties.Name -contains $RequiredGate)) {
    Write-Error "Gate '$RequiredGate' missing in session file '$sessionPath'."
    exit 1
}

$gateValue = $session.gates.$RequiredGate

if ($gateValue -ne $true) {
    Write-Error "Gate '$RequiredGate' is false for session '$sessionPath'. Ask user (sim) before proceeding."
    exit 1
}

Write-Host "Gate '$RequiredGate' approved ($sessionPath)"
exit 0
