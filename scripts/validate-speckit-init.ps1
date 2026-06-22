#Requires -Version 5.1
<#
.SYNOPSIS
  Validates Spec Kit initialization at the resolved storage path.

.DESCRIPTION
  Called by validate-all.ps1 when -IncludeSpeckit is set.

.PARAMETER RepoPath
  Consumer repository path (used to resolve manifest speckit section).

.PARAMETER SpecifyRoot
  Direct path to folder containing .specify/ (overrides manifest resolution).

.EXAMPLE
  .\scripts\validate-speckit-init.ps1 -RepoPath "D:\Source\Repos\MyApp"
#>
[CmdletBinding()]
param(
    [string] $RepoPath = (Get-Location).Path,
    [string] $SpecifyRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-SpeckitRoot {
    param([string] $Cwd)

    if ($SpecifyRoot) {
        return $SpecifyRoot.Replace('\', '/').TrimEnd('/')
    }

    $manifestPath = Join-Path $env:USERPROFILE '.cursor\sdd\manifest.json'
    if (-not (Test-Path -LiteralPath $manifestPath)) {
        return $Cwd.Replace('\', '/').TrimEnd('/')
    }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $key = $Cwd.Replace('\', '/').TrimEnd('/')
    $entry = $manifest.repositories.$key

    if (-not $entry) {
        return $key
    }

    if ($entry.PSObject.Properties.Name -contains 'speckit') {
        $mode = $entry.speckit.storage_mode
        $path = $entry.speckit.path
    }
    elseif ($entry.PSObject.Properties.Name -contains 'storage_mode') {
        $mode = $entry.storage_mode
        $path = $entry.path
    }
    else {
        return $key
    }

    if ($mode -eq 'repository') {
        return $key
    }

    return $path.Replace('\', '/').TrimEnd('/')
}

$root = Resolve-SpeckitRoot -Cwd $RepoPath
$specifyDir = Join-Path $root '.specify'
$constitutionPath = Join-Path $specifyDir 'memory\constitution.md'
$commandsDir = Join-Path $specifyDir 'commands'

$errors = @()

if (-not (Test-Path -LiteralPath $specifyDir)) {
    $errors += ".specify/ folder missing at: $root"
}

if (-not (Test-Path -LiteralPath $constitutionPath)) {
    $errors += "constitution.md missing at: $constitutionPath"
}
else {
    $content = Get-Content -LiteralPath $constitutionPath -Raw
    if ($content -match '\[PRINCIPLE_1_NAME\]') {
        $errors += 'constitution.md still contains placeholders — run speckit-init'
    }
}

if (-not (Test-Path -LiteralPath $commandsDir)) {
    $errors += "commands/ folder missing at: $commandsDir"
}

if ($errors.Count -gt 0) {
    Write-Host 'Spec Kit init validation FAILED:' -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "  - $e" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Spec Kit init OK at: $root" -ForegroundColor Green
exit 0
