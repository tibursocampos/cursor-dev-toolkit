#Requires -Version 5.1
<#
.SYNOPSIS
  Creates a timestamped backup of Cursor deploy targets before sync overwrite.
#>
function Get-ToolkitUserHome {
    if (-not [string]::IsNullOrWhiteSpace($env:HOME)) { return $env:HOME }
    return [Environment]::GetFolderPath('UserProfile')
}

function New-CursorToolkitBackup {
    param(
        [switch] $DryRun
    )

    $home = Get-ToolkitUserHome
    $cursorRoot = Join-Path $home '.cursor'
    $backupRoot = Join-Path $cursorRoot 'toolkit-backups'
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupDir = Join-Path $backupRoot $stamp

    $targets = @(
        @{ Name = 'skills'; Path = Join-Path $cursorRoot 'skills' },
        @{ Name = 'rules'; Path = Join-Path $cursorRoot 'rules' },
        @{ Name = 'hooks'; Path = Join-Path $cursorRoot 'hooks' },
        @{ Name = 'AGENTS.md'; Path = Join-Path $cursorRoot 'AGENTS.md'; IsFile = $true }
    )

    $existing = @($targets | Where-Object { Test-Path -LiteralPath $_.Path })
    if ($existing.Count -eq 0) {
        Write-Host '[cursor-dev-toolkit] No existing deploy to backup.' -ForegroundColor DarkGray
        return $null
    }

    if ($DryRun) {
        Write-Host "[cursor-dev-toolkit] Would backup to: $backupDir" -ForegroundColor Cyan
        return $backupDir
    }

    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    foreach ($t in $existing) {
        $dest = Join-Path $backupDir $t.Name
        if ($t.IsFile) {
            Copy-Item -LiteralPath $t.Path -Destination $dest -Force
        }
        else {
            Copy-Item -LiteralPath $t.Path -Destination $dest -Recurse -Force
        }
    }

    $manifest = @{
        createdUtc = [datetime]::UtcNow.ToString('o')
        source     = $cursorRoot
        targets    = @($existing | ForEach-Object { $_.Name })
    } | ConvertTo-Json
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Join-Path $backupDir 'backup-manifest.json'), $manifest, $utf8)

    Write-Host "[cursor-dev-toolkit] Backup created: $backupDir" -ForegroundColor Green
    return $backupDir
}
