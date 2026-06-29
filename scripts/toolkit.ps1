#Requires -Version 5.1
<#
.SYNOPSIS
  Interactive CLI orchestrator for the Cursor Dev Toolkit.

.DESCRIPTION
  Provides a menu to run sync, validations, and maintenance scripts without
  needing to remember individual script paths or parameters.
#>
$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

function Show-Menu {
    Clear-Host
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host ' Cursor Toolkit - Smart Manager' -ForegroundColor Cyan
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host '[1] Sync toolkit (deploy to ~/.cursor/)'
    Write-Host '[2] Run smoke tests (core)'
    Write-Host '[3] Deploy and test (sync + smoke tests)'
    Write-Host '[4] Full validation (includes Spec Kit and session gates)'
    Write-Host '[5] Maintainer suite (normalize encoding, fix/inject gates)'
    Write-Host '[6] Configure current repo for SDD (setup-speckit and config)'
    Write-Host '[7] Uninstall toolkit from ~/.cursor/ (-DryRun preview)'
    Write-Host '[0] Exit'
    Write-Host '=========================================' -ForegroundColor Cyan
}

function Run-Script {
    param([string]$Path, [string]$ArgsStr = '')
    Write-Host "`n>>> Running: $Path $ArgsStr" -ForegroundColor Yellow
    $fullPath = Join-Path $scriptDir $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "Error: file not found ($fullPath)" -ForegroundColor Red
        return $false
    }

    $pwshExe = (Get-Process -Id $PID).Path
    $procArgs = @('-ExecutionPolicy', 'Bypass', '-File', $fullPath)
    if (-not [string]::IsNullOrWhiteSpace($ArgsStr)) {
        $procArgs += $ArgsStr.Split(' ', [StringSplitOptions]::RemoveEmptyEntries)
    }

    & $pwshExe @procArgs

    if ($LASTEXITCODE -eq 0) {
        Write-Host ">>> Success: $Path" -ForegroundColor Green
        return $true
    }

    Write-Host ">>> Failed (ExitCode: $LASTEXITCODE): $Path" -ForegroundColor Red
    return $false
}

while ($true) {
    Show-Menu
    $choice = Read-Host 'Choose an option'

    switch ($choice) {
        '1' {
            Run-Script 'sync-cursor.ps1'
        }
        '2' {
            Run-Script 'validation\validate-all.ps1'
        }
        '3' {
            if (Run-Script 'sync-cursor.ps1') {
                Run-Script 'validation\validate-all.ps1'
            }
        }
        '4' {
            Run-Script 'validation\validate-all.ps1' '-IncludeSpeckit -IncludeSessionGate'
        }
        '5' {
            Write-Host "`nStarting maintainer suite..." -ForegroundColor Cyan
            Run-Script 'maintainers\normalize-skill-encoding.ps1'
            Run-Script 'maintainers\fix-skill-gates.ps1'
            Run-Script 'maintainers\inject-skill-gates.ps1'
        }
        '6' {
            if (Run-Script 'setup-speckit.ps1') {
                Run-Script 'configure-repo-sdd.ps1'
            }
        }
        '7' {
            Run-Script 'uninstall-toolkit.ps1' '-DryRun'
            $confirm = Read-Host 'Proceed with uninstall? (yes/no)'
            if ($confirm -eq 'yes') {
                Run-Script 'uninstall-toolkit.ps1'
            }
        }
        '0' {
            Write-Host 'Exiting...' -ForegroundColor Cyan
            exit 0
        }
        default {
            Write-Host 'Invalid option.' -ForegroundColor Red
        }
    }

    Write-Host "`nPress Enter to continue..." -ForegroundColor DarkGray
    $null = Read-Host
}
