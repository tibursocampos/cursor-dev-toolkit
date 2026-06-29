#Requires -Version 5.1
<#
.SYNOPSIS
  Validates session gates for the active repository.

.DESCRIPTION
  Called by validate-all.ps1 when -IncludeSessionGate is set.

.PARAMETER RepoPath
  Workspace path (defaults to current location).

.PARAMETER RequiredGate
  Gate name: storage_confirmed, write_confirmed, step_confirmed, tests_run

.EXAMPLE
  .\scripts\validation\validate-session-gates.ps1 -RepoPath "D:\Source\Repos\MyApp" -RequiredGate write_confirmed
#>
[CmdletBinding()]
param(
    [string] $RepoPath = (Get-Location).Path,
    [Parameter(Mandatory = $true)]
    [ValidateSet('storage_confirmed', 'write_confirmed', 'step_confirmed', 'tests_run')]
    [string] $RequiredGate
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepoHash([string] $Path) {
    $normalized = $Path.Replace('\', '/').TrimEnd('/')
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($normalized)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    $hex = [BitConverter]::ToString($hash).Replace('-', '').ToLowerInvariant()
    return $hex.Substring(0, 16)
}

$sessionsDir = Join-Path $env:USERPROFILE '.cursor\sdd\sessions'
$repoHash = Get-RepoHash $RepoPath
$sessionPath = Join-Path $sessionsDir "$repoHash.json"

if (-not (Test-Path -LiteralPath $sessionPath)) {
    Write-Error "Session file not found: $sessionPath. Gate '$RequiredGate' is not approved."
    exit 1
}

$session = Get-Content -LiteralPath $sessionPath -Raw | ConvertFrom-Json
$gateValue = $session.gates.$RequiredGate

if ($gateValue -ne $true) {
    Write-Error "Gate '$RequiredGate' is false for repo '$RepoPath'. Ask user (sim) before proceeding."
    exit 1
}

Write-Host "Gate '$RequiredGate' approved for $RepoPath"
exit 0
