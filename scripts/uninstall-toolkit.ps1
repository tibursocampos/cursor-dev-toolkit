#Requires -Version 5.1
<#
.SYNOPSIS
  Uninstalls cursor-dev-toolkit from ~/.cursor/.

.DESCRIPTION
  Removes toolkit-deployed skills, rules, hooks, AGENTS.md, and SDD session state.
  Does not remove unrelated user Cursor settings.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/uninstall-toolkit.ps1 -DryRun
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:ToolkitTag = '[cursor-dev-toolkit]'

function Write-ToolkitMessage {
    param(
        [string] $Message,
        [ConsoleColor] $Color = [ConsoleColor]::Gray
    )
    Write-Host "$script:ToolkitTag $Message" -ForegroundColor $Color
}

$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$repoRoot = Split-Path -Parent $scriptDir
$cursorRoot = Join-Path $env:USERPROFILE '.cursor'

$totalChanges = 0

function Remove-IfExists {
    param(
        [string] $Path,
        [string] $Label
    )
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $script:totalChanges++
    if ($DryRun) {
        Write-ToolkitMessage "Would remove $Label : $Path" ([ConsoleColor]::Cyan)
    }
    else {
        if ((Get-Item -LiteralPath $Path).PSIsContainer) {
            Remove-Item -LiteralPath $Path -Recurse -Force
        }
        else {
            Remove-Item -LiteralPath $Path -Force
        }
        Write-ToolkitMessage "Removed $Label : $Path" ([ConsoleColor]::DarkRed)
    }
}

$skillDirs = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'skills') -Directory |
    Where-Object { $_.Name -ne '_shared' }

foreach ($dir in $skillDirs) {
    Remove-IfExists (Join-Path $cursorRoot "skills\$($dir.Name)") "skill folder $($dir.Name)"
}

Remove-IfExists (Join-Path $cursorRoot 'skills\_shared') 'shared skills folder'
Remove-IfExists (Join-Path $cursorRoot 'AGENTS.md') 'AGENTS.md'
Remove-IfExists (Join-Path $cursorRoot 'hooks') 'hooks directory'
Remove-IfExists (Join-Path $cursorRoot 'hooks.json') 'hooks.json'
Remove-IfExists (Join-Path $cursorRoot 'sdd\sessions') 'SDD sessions directory'

$ruleFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'rules') -Filter '*.md' -ErrorAction SilentlyContinue
foreach ($rule in $ruleFiles) {
    $mdcName = [System.IO.Path]::ChangeExtension($rule.Name, '.mdc')
    Remove-IfExists (Join-Path $cursorRoot "rules\$mdcName") "rule $mdcName"
}

Write-Host ''
if ($totalChanges -eq 0) {
    Write-ToolkitMessage 'Uninstall complete - nothing to remove.' ([ConsoleColor]::Green)
}
elseif ($DryRun) {
    Write-ToolkitMessage "Dry run complete - $totalChanges item(s) would be removed." ([ConsoleColor]::Cyan)
}
else {
    Write-ToolkitMessage "Uninstall complete - $totalChanges item(s) removed." ([ConsoleColor]::Green)
    Write-ToolkitMessage 'Restart Cursor IDE to clear cached skills and rules.' ([ConsoleColor]::Yellow)
}

exit 0
