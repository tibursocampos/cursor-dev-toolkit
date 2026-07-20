#Requires -Version 5.1
<#
.SYNOPSIS
  Restores a previous cursor-dev-toolkit sync backup under ~/.cursor/toolkit-backups/.

.PARAMETER BackupId
  Timestamp folder name (yyyyMMdd-HHmmss). If omitted, lists available backups.

.PARAMETER DryRun
  Show what would be restored.

.EXAMPLE
  .\scripts\restore-toolkit-backup.ps1
  .\scripts\restore-toolkit-backup.ps1 -BackupId 20260720-091500
#>
[CmdletBinding()]
param(
    [string] $BackupId,
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib\Backup-CursorToolkit.ps1')

$home = Get-ToolkitUserHome
$cursorRoot = Join-Path $home '.cursor'
$backupRoot = Join-Path $cursorRoot 'toolkit-backups'

if (-not (Test-Path -LiteralPath $backupRoot)) {
    Write-Host "No backups found at $backupRoot" -ForegroundColor Yellow
    exit 0
}

$available = @(Get-ChildItem -LiteralPath $backupRoot -Directory | Sort-Object Name -Descending)
if ($available.Count -eq 0) {
    Write-Host "No backup folders under $backupRoot" -ForegroundColor Yellow
    exit 0
}

if ([string]::IsNullOrWhiteSpace($BackupId)) {
    Write-Host 'Available backups (newest first):' -ForegroundColor Cyan
    $available | ForEach-Object { Write-Host "  $($_.Name)" }
    Write-Host ''
    Write-Host 'Re-run with -BackupId <id> to restore.' -ForegroundColor DarkGray
    exit 0
}

$backupDir = Join-Path $backupRoot $BackupId
if (-not (Test-Path -LiteralPath $backupDir)) {
    Write-Host "Backup not found: $backupDir" -ForegroundColor Red
    exit 1
}

$map = @(
    @{ Src = 'skills'; Dest = Join-Path $cursorRoot 'skills'; IsDir = $true },
    @{ Src = 'rules'; Dest = Join-Path $cursorRoot 'rules'; IsDir = $true },
    @{ Src = 'hooks'; Dest = Join-Path $cursorRoot 'hooks'; IsDir = $true },
    @{ Src = 'AGENTS.md'; Dest = Join-Path $cursorRoot 'AGENTS.md'; IsDir = $false }
)

foreach ($item in $map) {
    $src = Join-Path $backupDir $item.Src
    if (-not (Test-Path -LiteralPath $src)) { continue }
    if ($DryRun) {
        Write-Host "Would restore $($item.Src) -> $($item.Dest)" -ForegroundColor Cyan
        continue
    }
    if ($item.IsDir) {
        if (Test-Path -LiteralPath $item.Dest) {
            Remove-Item -LiteralPath $item.Dest -Recurse -Force
        }
        Copy-Item -LiteralPath $src -Destination $item.Dest -Recurse -Force
    }
    else {
        $parent = Split-Path -Parent $item.Dest
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Copy-Item -LiteralPath $src -Destination $item.Dest -Force
    }
    Write-Host "Restored $($item.Src)" -ForegroundColor Green
}

Write-Host "Restore complete from $BackupId" -ForegroundColor Green
exit 0
