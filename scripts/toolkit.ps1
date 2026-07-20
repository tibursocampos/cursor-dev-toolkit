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

. (Join-Path $scriptDir '_lib\Get-ToolkitRepoRoot.ps1')
$repoRoot = Get-ToolkitRepoRoot -FromPath $scriptDir

function Show-Menu {
    Write-Host ''
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host ' Cursor Toolkit - Smart Manager' -ForegroundColor Cyan
    Write-Host " Repo: $repoRoot" -ForegroundColor DarkGray
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host '[1] Sync toolkit (deploy to ~/.cursor/)'
    Write-Host '[2] Run smoke tests (validate-all)'
    Write-Host '[3] Deploy and test (sync + validate-all)'
    Write-Host '[4] Full validation (+ session gates)'
    Write-Host '[5] Maintainer suite (normalize encoding, fix/inject gates)'
    Write-Host '[6] Configure toolkit repo for SDD (configure-repo-sdd)'
    Write-Host '[7] Uninstall toolkit from ~/.cursor/ (-DryRun preview)'
    Write-Host '[8] Validation and backup (submenu)'
    Write-Host '[0] Exit'
    Write-Host '=========================================' -ForegroundColor Cyan
}

function Show-ValidationBackupMenu {
    Write-Host ''
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host ' Validation and backup' -ForegroundColor Cyan
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host '[1] validate-all (full suite)'
    Write-Host '[2] skill-contracts only'
    Write-Host '[3] skill-graph only'
    Write-Host '[4] skill-fixtures only'
    Write-Host '[5] docs-consistency only'
    Write-Host '[6] List sync backups'
    Write-Host '[7] Restore backup (asks for BackupId)'
    Write-Host '[0] Back'
    Write-Host '=========================================' -ForegroundColor Cyan
}

function Write-StepBanner {
    param(
        [string] $Title,
        [ConsoleColor] $Color = [ConsoleColor]::Cyan
    )
    Write-Host ''
    Write-Host "========== $Title ==========" -ForegroundColor $Color
}

function Invoke-ToolkitScript {
    param(
        [string] $RelativePath,
        [string[]] $ArgumentList = @()
    )

    $fullPath = Join-Path $scriptDir $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        Write-Host "Error: file not found ($fullPath)" -ForegroundColor Red
        return $false
    }

    $argDisplay = ($ArgumentList -join ' ').Trim()
    if ([string]::IsNullOrWhiteSpace($argDisplay)) {
        Write-Host "`n>>> Running: $RelativePath" -ForegroundColor Yellow
    }
    else {
        Write-Host "`n>>> Running: $RelativePath $argDisplay" -ForegroundColor Yellow
    }

    $exitCode = 0
    try {
        & $fullPath @ArgumentList
        $exitCode = $LASTEXITCODE
        if ($null -eq $exitCode) {
            $exitCode = 0
        }
    }
    catch {
        Write-Host ">>> Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    if ($exitCode -eq 0) {
        Write-Host ">>> Success: $RelativePath (exit 0)" -ForegroundColor Green
        return $true
    }

    Write-Host ">>> Failed: $RelativePath (exit $exitCode)" -ForegroundColor Red
    return $false
}

function Write-WorkflowSummary {
    param(
        [hashtable] $Steps
    )

    Write-Host ''
    Write-Host '========== Workflow summary ==========' -ForegroundColor Cyan
    foreach ($name in $Steps.Keys) {
        $status = $Steps[$name]
        $color = switch ($status) {
            'PASS' { [ConsoleColor]::Green }
            'FAIL' { [ConsoleColor]::Red }
            'SKIP' { [ConsoleColor]::DarkGray }
            default { [ConsoleColor]::Gray }
        }
        Write-Host ("  {0,-12} {1}" -f "${name}:", $status) -ForegroundColor $color
    }
}

function Invoke-ValidationBackupSubmenu {
    while ($true) {
        Show-ValidationBackupMenu
        $sub = Read-Host 'Choose an option'
        switch ($sub) {
            '1' {
                Write-StepBanner 'validate-all'
                $null = Invoke-ToolkitScript -RelativePath 'validation\validate-all.ps1'
            }
            '2' {
                Write-StepBanner 'skill-contracts'
                $null = Invoke-ToolkitScript -RelativePath 'validation\validate-skill-contracts.ps1'
            }
            '3' {
                Write-StepBanner 'skill-graph'
                $null = Invoke-ToolkitScript -RelativePath 'validation\validate-skill-graph.ps1'
            }
            '4' {
                Write-StepBanner 'skill-fixtures'
                $null = Invoke-ToolkitScript -RelativePath 'validation\validate-skill-fixtures.ps1'
            }
            '5' {
                Write-StepBanner 'docs-consistency'
                $null = Invoke-ToolkitScript -RelativePath 'validation\validate-docs-consistency.ps1'
            }
            '6' {
                Write-StepBanner 'List sync backups'
                $null = Invoke-ToolkitScript -RelativePath 'restore-toolkit-backup.ps1'
            }
            '7' {
                Write-StepBanner 'Restore sync backup'
                $backupId = Read-Host 'BackupId (yyyyMMdd-HHmmss)'
                if ([string]::IsNullOrWhiteSpace($backupId)) {
                    Write-Host 'Restore cancelled (empty BackupId).' -ForegroundColor DarkGray
                }
                else {
                    $null = Invoke-ToolkitScript -RelativePath 'restore-toolkit-backup.ps1' -ArgumentList @('-BackupId', $backupId)
                }
            }
            '0' {
                return
            }
            default {
                Write-Host 'Invalid option.' -ForegroundColor Red
            }
        }

        Write-Host ''
        Write-Host 'Press Enter to continue...' -ForegroundColor DarkGray
        $null = Read-Host
    }
}

while ($true) {
    Show-Menu
    $choice = Read-Host 'Choose an option'

    switch ($choice) {
        '1' {
            Write-StepBanner 'Sync to ~/.cursor/'
            $null = Invoke-ToolkitScript -RelativePath 'sync-cursor.ps1'
        }
        '2' {
            Write-StepBanner 'Smoke tests (validate-all)'
            $null = Invoke-ToolkitScript -RelativePath 'validation\validate-all.ps1'
        }
        '3' {
            Write-StepBanner 'Step 1/2: Sync to ~/.cursor/'
            $syncOk = Invoke-ToolkitScript -RelativePath 'sync-cursor.ps1'
            Write-Host ("Sync step finished: {0}" -f $(if ($syncOk) { 'OK' } else { 'FAILED' })) -ForegroundColor $(if ($syncOk) { 'Green' } else { 'Red' })

            $validateOk = $false
            if ($syncOk) {
                Write-StepBanner 'Step 2/2: Smoke tests'
                $validateOk = Invoke-ToolkitScript -RelativePath 'validation\validate-all.ps1'
            }
            else {
                Write-Host 'Skipping smoke tests because sync failed.' -ForegroundColor Yellow
            }

            Write-WorkflowSummary @{
                Sync  = if ($syncOk) { 'PASS' } else { 'FAIL' }
                Smoke = if (-not $syncOk) { 'SKIP' } elseif ($validateOk) { 'PASS' } else { 'FAIL' }
            }
        }
        '4' {
            Write-StepBanner 'Full validation (session gates)'
            $null = Invoke-ToolkitScript -RelativePath 'validation\validate-all.ps1' -ArgumentList @(
                '-IncludeSessionGate',
                '-RepoPath',
                $repoRoot
            )
        }
        '5' {
            Write-StepBanner 'Maintainer suite'
            $normalizeOk = Invoke-ToolkitScript -RelativePath 'maintainers\normalize-skill-encoding.ps1'
            $fixGatesOk = Invoke-ToolkitScript -RelativePath 'maintainers\fix-skill-gates.ps1'
            $injectGatesOk = Invoke-ToolkitScript -RelativePath 'maintainers\inject-skill-gates.ps1'
            Write-WorkflowSummary @{
                Normalize = if ($normalizeOk) { 'PASS' } else { 'FAIL' }
                FixGates  = if ($fixGatesOk) { 'PASS' } else { 'FAIL' }
                Inject    = if ($injectGatesOk) { 'PASS' } else { 'FAIL' }
            }
        }
        '6' {
            Write-StepBanner 'Configure manifest for toolkit repo'
            $configOk = Invoke-ToolkitScript -RelativePath 'configure-repo-sdd.ps1' -ArgumentList @(
                '-StorageMode',
                'global',
                '-RepoPath',
                $repoRoot
            )
            Write-WorkflowSummary @{
                ConfigureSdd = if ($configOk) { 'PASS' } else { 'FAIL' }
            }
        }
        '7' {
            Write-StepBanner 'Uninstall preview (-DryRun)'
            $null = Invoke-ToolkitScript -RelativePath 'uninstall-toolkit.ps1' -ArgumentList @('-DryRun')
            $confirm = Read-Host 'Proceed with uninstall? (yes/no)'
            if ($confirm -eq 'yes') {
                Write-StepBanner 'Uninstall toolkit from ~/.cursor/'
                $null = Invoke-ToolkitScript -RelativePath 'uninstall-toolkit.ps1'
            }
            else {
                Write-Host 'Uninstall cancelled.' -ForegroundColor DarkGray
            }
        }
        '8' {
            Invoke-ValidationBackupSubmenu
            continue
        }
        '0' {
            Write-Host 'Exiting...' -ForegroundColor Cyan
            exit 0
        }
        default {
            Write-Host 'Invalid option.' -ForegroundColor Red
        }
    }

    Write-Host ''
    Write-Host 'Press Enter to continue...' -ForegroundColor DarkGray
    $null = Read-Host
}
