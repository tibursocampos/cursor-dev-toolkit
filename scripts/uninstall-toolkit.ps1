#Requires -Version 5.1
<#
.SYNOPSIS
  Uninstalls cursor-dev-toolkit from ~/.cursor/.

.DESCRIPTION
  Removes toolkit-deployed skills, rules, AGENTS.md, and SDD session state.
  Hook scripts are removed only when they match files shipped in this repo's hooks/.
  hooks.json is rewritten to drop toolkit command entries; user hook entries are kept.
  Does not remove unrelated user Cursor settings or custom skill folders.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/uninstall-toolkit.ps1 -DryRun
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
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

function Get-HookCommandKey {
    param($Entry)
    if ($null -eq $Entry) { return $null }
    if ($Entry -is [string]) { return $Entry }
    if ($Entry.PSObject.Properties.Name -contains 'command') {
        return [string]$Entry.command
    }
    return $null
}

function Test-IsToolkitHookCommand {
    param(
        [string] $Command,
        [string[]] $ToolkitScriptNames
    )
    if ([string]::IsNullOrWhiteSpace($Command)) { return $false }
    foreach ($name in $ToolkitScriptNames) {
        if ($Command -match [regex]::Escape($name)) {
            return $true
        }
    }
    return $false
}

$scriptDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$repoRoot = Split-Path -Parent $scriptDir
$cursorRoot = Join-Path $env:USERPROFILE '.cursor'
$repoHooksDir = Join-Path $repoRoot 'hooks'

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
        return
    }
    if (-not $PSCmdlet.ShouldProcess($Path, "Remove $Label")) {
        return
    }
    if ((Get-Item -LiteralPath $Path).PSIsContainer) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    else {
        Remove-Item -LiteralPath $Path -Force
    }
    Write-ToolkitMessage "Removed $Label : $Path" ([ConsoleColor]::DarkRed)
}

$skillDirs = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'skills') -Directory |
    Where-Object { $_.Name -ne '_shared' }

foreach ($dir in $skillDirs) {
    Remove-IfExists (Join-Path $cursorRoot "skills\$($dir.Name)") "skill folder $($dir.Name)"
}

Remove-IfExists (Join-Path $cursorRoot 'skills\_shared') 'shared skills folder'
Remove-IfExists (Join-Path $cursorRoot 'AGENTS.md') 'AGENTS.md'
Remove-IfExists (Join-Path $cursorRoot 'sdd\sessions') 'SDD sessions directory'

$toolkitHookScripts = @()
if (Test-Path -LiteralPath $repoHooksDir) {
    $toolkitHookScripts = @(Get-ChildItem -LiteralPath $repoHooksDir -Filter '*.ps1' -File | ForEach-Object { $_.Name })
    foreach ($hookScript in $toolkitHookScripts) {
        Remove-IfExists (Join-Path $cursorRoot "hooks\$hookScript") "toolkit hook $hookScript"
    }
}

$hooksJsonPath = Join-Path $cursorRoot 'hooks.json'
if (Test-Path -LiteralPath $hooksJsonPath) {
    try {
        $hooksDoc = Get-Content -LiteralPath $hooksJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $changed = $false
        if ($hooksDoc.hooks) {
            foreach ($eventName in @($hooksDoc.hooks.PSObject.Properties.Name)) {
                $entries = @($hooksDoc.hooks.$eventName)
                $kept = @()
                foreach ($entry in $entries) {
                    $cmd = Get-HookCommandKey $entry
                    if (Test-IsToolkitHookCommand -Command $cmd -ToolkitScriptNames $toolkitHookScripts) {
                        $changed = $true
                        continue
                    }
                    $kept += $entry
                }
                $hooksDoc.hooks.$eventName = $kept
            }
        }

        if ($changed) {
            $script:totalChanges++
            if ($DryRun) {
                Write-ToolkitMessage "Would rewrite hooks.json (drop toolkit entries only): $hooksJsonPath" ([ConsoleColor]::Cyan)
            }
            elseif ($PSCmdlet.ShouldProcess($hooksJsonPath, 'Remove toolkit hook entries')) {
                $json = $hooksDoc | ConvertTo-Json -Depth 8
                Set-Content -LiteralPath $hooksJsonPath -Value $json -Encoding UTF8
                Write-ToolkitMessage "Rewrote hooks.json (toolkit entries removed)" ([ConsoleColor]::Yellow)
            }
        }
    }
    catch {
        Write-ToolkitMessage "Could not surgically edit hooks.json: $($_.Exception.Message). Leaving file intact." ([ConsoleColor]::Yellow)
    }
}

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
