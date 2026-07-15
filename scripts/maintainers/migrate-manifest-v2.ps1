#Requires -Version 5.1
<#
.SYNOPSIS
  Migrates legacy SDD manifests to schema v2 (classic section only).

.EXAMPLE
  .\scripts\maintainers\migrate-manifest-v2.ps1
  .\scripts\maintainers\migrate-manifest-v2.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$manifestPath = Join-Path $env:USERPROFILE '.cursor\sdd\manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Host 'No manifest.json found — nothing to migrate.' -ForegroundColor Yellow
    exit 0
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$changed = $false

if ($manifest.PSObject.Properties.Name -notcontains 'schema_version') {
    $manifest | Add-Member -NotePropertyName 'schema_version' -NotePropertyValue 2 -Force
    $changed = $true
}

if (-not $manifest.repositories) {
    Write-Host 'Manifest has no repositories — schema_version only.' -ForegroundColor Yellow
    if ($changed -and -not $DryRun) {
        $manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Encoding UTF8
    }
    exit 0
}

foreach ($repoKey in @($manifest.repositories.PSObject.Properties.Name)) {
    $entry = $manifest.repositories.$repoKey
    if ($entry.PSObject.Properties.Name -contains 'classic') {
        continue
    }
    if ($entry.PSObject.Properties.Name -notcontains 'storage_mode') {
        continue
    }

    $mode = [string]$entry.storage_mode
    $path = [string]$entry.path
    $newEntry = [PSCustomObject]@{
        classic = [PSCustomObject]@{
            storage_mode = $mode
            path         = $path
        }
    }
    $manifest.repositories.$repoKey = $newEntry
    Write-Host "Migrated repository entry: $repoKey" -ForegroundColor Cyan
    $changed = $true
}

if (-not $changed) {
    Write-Host 'Manifest already schema v2 — no changes.' -ForegroundColor Green
    exit 0
}

if ($DryRun) {
    Write-Host 'Dry run — would write schema v2 manifest (classic only).' -ForegroundColor Yellow
    exit 0
}

$manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host 'Manifest migrated to schema v2 (classic only).' -ForegroundColor Green
exit 0
