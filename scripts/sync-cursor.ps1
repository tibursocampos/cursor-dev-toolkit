#Requires -Version 5.1
<#
.SYNOPSIS
  Deploys cursor-dev-toolkit to the user Cursor directory (~/.cursor/).

.DESCRIPTION
  Copies AGENTS.md, skills/ (including Forma C / memory-bank and Caveman Mode), rules/ (.md -> .mdc), and hooks/ PowerShell scripts.
  Merges hooks/hooks.json into ~/.cursor/hooks.json without removing user hook entries.
  By default preserves top-level skill folders under ~/.cursor/skills that are absent from the repo.
  Pass -PruneStaleSkills to remove those extras (mirror prune). File-level mirror cleanup inside toolkit skill folders still runs.
  Does not overwrite Cursor user settings or unrelated files under ~/.cursor/.

.PARAMETER Force
  Reserved for future prompts; currently has no effect.

.PARAMETER PruneStaleSkills
  Remove top-level skill folders under ~/.cursor/skills that are absent from the toolkit repo.
  Opt-in: default sync keeps custom/extra skills beside the toolkit.

.PARAMETER KeepExtraSkills
  Deprecated alias of the new default (preserve extras). Kept for backward compatibility.
  Ignored when -PruneStaleSkills is set unless both are passed (then extras are kept).

.PARAMETER DryRun
  Report planned changes without writing files.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1 -DryRun

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-cursor.ps1 -PruneStaleSkills
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch] $Force,
    [switch] $PruneStaleSkills,
    [switch] $KeepExtraSkills,
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

function Get-RepoRoot {
    $scriptDir = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptDir)) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    return (Resolve-Path (Join-Path $scriptDir '..')).Path
}

function Get-FileSha256([string] $Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function ConvertTo-CleanJson {
    param(
        $Object,
        [int] $Depth = 10
    )
    $raw = $Object | ConvertTo-Json -Depth $Depth
    $raw = [regex]::Replace($raw, '\\u([0-9a-fA-F]{4})', {
        param($m)
        $cp = [Convert]::ToInt32($m.Groups[1].Value, 16)
        if ($cp -ge 0x20 -and $cp -ne 0x22 -and $cp -ne 0x5C) {
            [char]$cp
        }
        else {
            $m.Value
        }
    })
    $lines = $raw -split "`n"
    ($lines | ForEach-Object {
        if ($_ -match '^( {4,})') {
            $depth = [math]::Floor($Matches[1].Length / 4)
            ('  ' * $depth) + $_.TrimStart()
        }
        else {
            $_
        }
    }) -join "`n"
}

function Write-Utf8NoBom([string] $Path, [string] $Content) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Copy-FileIfChanged {
    param(
        [string] $SourcePath,
        [string] $DestPath
    )
    $destDir = Split-Path -Parent $DestPath
    if (-not (Test-Path -LiteralPath $destDir)) {
        if ($DryRun) {
            Write-ToolkitMessage "Would create directory: $destDir" ([ConsoleColor]::Cyan)
        }
        else {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
    }

    $sourceHash = Get-FileSha256 $SourcePath
    $destHash = Get-FileSha256 $DestPath
    if ($sourceHash -eq $destHash) {
        return $false
    }

    $relative = $DestPath
    if ($DryRun) {
        Write-ToolkitMessage "Would sync: $relative" ([ConsoleColor]::Cyan)
        return $true
    }

    Copy-Item -LiteralPath $SourcePath -Destination $DestPath -Force
    Write-ToolkitMessage "Synced: $relative" ([ConsoleColor]::Green)
    return $true
}

function Sync-DirectoryTree {
    param(
        [string] $SourceRoot,
        [string] $DestRoot,
        [string[]] $ExcludeFileNames = @()
    )
    if (-not (Test-Path -LiteralPath $SourceRoot)) {
        return 0
    }

    $changed = 0
    Get-ChildItem -LiteralPath $SourceRoot -Recurse -File |
        Where-Object {
            $ExcludeFileNames -notcontains $_.Name -and
            $_.Name -ne '.gitkeep'
        } |
        ForEach-Object {
            $relative = $_.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
            $destPath = Join-Path $DestRoot $relative
            if (Copy-FileIfChanged -SourcePath $_.FullName -DestPath $destPath) {
                $changed++
            }
        }
    return $changed
}

function Get-TopLevelDirectoryNames {
    param([string] $Root)
    if (-not (Test-Path -LiteralPath $Root)) {
        return @()
    }
    return @(Get-ChildItem -LiteralPath $Root -Directory | ForEach-Object { $_.Name })
}

function Remove-StaleSkillDirectories {
    param(
        [string] $RepoSkillsRoot,
        [string] $DestSkillsRoot
    )
    # Default: keep custom/extra skills. Prune only when explicitly requested.
    if (-not $PruneStaleSkills -or $KeepExtraSkills) {
        return 0
    }
    if (-not (Test-Path -LiteralPath $DestSkillsRoot)) {
        return 0
    }

    $expected = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($name in (Get-TopLevelDirectoryNames $RepoSkillsRoot)) {
        [void]$expected.Add($name)
    }

    $removed = 0
    Get-ChildItem -LiteralPath $DestSkillsRoot -Directory | ForEach-Object {
        if ($expected.Contains($_.Name)) {
            return
        }
        if ($DryRun) {
            Write-ToolkitMessage "Would remove stale skill directory: $($_.FullName)" ([ConsoleColor]::Cyan)
        }
        else {
            Remove-Item -LiteralPath $_.FullName -Recurse -Force
            Write-ToolkitMessage "Removed stale skill directory: $($_.Name)" ([ConsoleColor]::Yellow)
        }
        $removed++
    }
    return $removed
}

function Remove-EmptyDirectories {
    param([string] $Root)
    if (-not (Test-Path -LiteralPath $Root)) {
        return
    }
    Get-ChildItem -LiteralPath $Root -Recurse -Directory |
        Sort-Object { $_.FullName.Length } -Descending |
        ForEach-Object {
            $childItems = @(Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue)
            if ($childItems.Count -gt 0) {
                return
            }
            if ($DryRun) {
                Write-ToolkitMessage "Would remove empty directory: $($_.FullName)" ([ConsoleColor]::Cyan)
            }
            else {
                Remove-Item -LiteralPath $_.FullName -Force
                Write-ToolkitMessage "Removed empty directory: $($_.FullName)" ([ConsoleColor]::DarkYellow)
            }
        }
}

function Remove-StaleFilesInTree {
    param(
        [string] $SourceRoot,
        [string] $DestRoot,
        [string[]] $ExcludeFileNames = @()
    )
    if (-not (Test-Path -LiteralPath $DestRoot)) {
        return 0
    }

    $removed = 0
    Get-ChildItem -LiteralPath $DestRoot -Recurse -File |
        Where-Object {
            $ExcludeFileNames -notcontains $_.Name -and
            $_.Name -ne '.gitkeep'
        } |
        ForEach-Object {
            $relative = $_.FullName.Substring($DestRoot.Length).TrimStart('\', '/')
            $sourcePath = Join-Path $SourceRoot $relative
            if (Test-Path -LiteralPath $sourcePath) {
                return
            }
            if ($DryRun) {
                Write-ToolkitMessage "Would remove stale file: $($_.FullName)" ([ConsoleColor]::Cyan)
            }
            else {
                Remove-Item -LiteralPath $_.FullName -Force
                Write-ToolkitMessage "Removed stale file: $relative" ([ConsoleColor]::Yellow)
            }
            $removed++
        }

    Remove-EmptyDirectories -Root $DestRoot
    return $removed
}

function Remove-StaleRules {
    param(
        [string] $RulesSource,
        [string] $RulesDest
    )
    if (-not (Test-Path -LiteralPath $RulesDest)) {
        return 0
    }

    $removed = 0
    Get-ChildItem -LiteralPath $RulesDest -Filter '*.mdc' -File | ForEach-Object {
        $mdName = [System.IO.Path]::ChangeExtension($_.Name, '.md')
        $sourcePath = Join-Path $RulesSource $mdName
        if (Test-Path -LiteralPath $sourcePath) {
            return
        }
        if ($DryRun) {
            Write-ToolkitMessage "Would remove stale rule: $($_.FullName)" ([ConsoleColor]::Cyan)
        }
        else {
            Remove-Item -LiteralPath $_.FullName -Force
            Write-ToolkitMessage "Removed stale rule: $($_.Name)" ([ConsoleColor]::Yellow)
        }
        $removed++
    }
    return $removed
}

function Sync-Rules {
    param(
        [string] $RepoRoot,
        [string] $RulesDest
    )
    $rulesSource = Join-Path $RepoRoot 'rules'
    if (-not (Test-Path -LiteralPath $rulesSource)) {
        return 0
    }

    $changed = 0
    Get-ChildItem -LiteralPath $rulesSource -Filter '*.md' -File |
        ForEach-Object {
            $destName = [System.IO.Path]::ChangeExtension($_.Name, '.mdc')
            $destPath = Join-Path $RulesDest $destName
            if (Copy-FileIfChanged -SourcePath $_.FullName -DestPath $destPath) {
                $changed++
            }
        }
    return $changed
}

function Get-HookEntryArray($Entries) {
    if ($null -eq $Entries) {
        return @()
    }
    if ($Entries -is [System.Collections.ArrayList]) {
        return $Entries.ToArray()
    }
    if ($Entries -is [System.Array]) {
        return $Entries
    }
    if ($Entries.PSObject.Properties['command']) {
        return @($Entries)
    }
    return @($Entries)
}

function Get-HookCommandKey($Entry) {
    if ($null -eq $Entry) {
        return $null
    }
    $prop = $Entry.PSObject.Properties['command']
    if (-not $prop -or [string]::IsNullOrWhiteSpace([string]$prop.Value)) {
        return $null
    }
    return [string]$prop.Value
}

function Get-HookCommandSet($HookEntries) {
    $set = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    if ($null -eq $HookEntries) {
        return $set
    }
    foreach ($entry in (Get-HookEntryArray $HookEntries)) {
        $cmd = Get-HookCommandKey $entry
        if ($cmd) {
            [void]$set.Add($cmd)
        }
    }
    return ,$set
}

function Merge-HookEventEntries {
    param(
        $UserEntries,
        $ToolkitEntries
    )
    $merged = [System.Collections.ArrayList]::new()
    foreach ($entry in (Get-HookEntryArray $UserEntries)) {
        [void]$merged.Add($entry)
    }
    $existing = Get-HookCommandSet $merged
    foreach ($entry in (Get-HookEntryArray $ToolkitEntries)) {
        $cmd = Get-HookCommandKey $entry
        if ([string]::IsNullOrWhiteSpace($cmd)) {
            continue
        }
        if (-not $existing.Contains($cmd)) {
            [void]$merged.Add($entry)
            [void]$existing.Add($cmd)
        }
    }
    return @($merged)
}

function Get-HooksPayloadHashtable($HooksObject) {
    $hooksHash = [ordered]@{}
    foreach ($eventName in $HooksObject.PSObject.Properties.Name) {
        $hooksHash[$eventName] = @(Get-HookEntryArray $HooksObject.$eventName)
    }
    return $hooksHash
}

function Merge-HooksJsonContent {
    param(
        [string] $ToolkitHooksPath,
        [string] $UserHooksPath
    )
    $toolkit = Get-Content -LiteralPath $ToolkitHooksPath -Raw | ConvertFrom-Json
    $user = if (Test-Path -LiteralPath $UserHooksPath) {
        Get-Content -LiteralPath $UserHooksPath -Raw | ConvertFrom-Json
    }
    else {
        [PSCustomObject]@{ version = 1; hooks = [PSCustomObject]@{} }
    }

    if (-not ($user.PSObject.Properties['version'])) {
        $user | Add-Member -MemberType NoteProperty -Name 'version' -Value 1 -Force
    }
    if (-not ($user.PSObject.Properties['hooks'])) {
        $user | Add-Member -MemberType NoteProperty -Name 'hooks' -Value ([PSCustomObject]@{}) -Force
    }

    $changed = $false
    foreach ($eventName in $toolkit.hooks.PSObject.Properties.Name) {
        $toolkitEntries = $toolkit.hooks.$eventName
        $userProp = $user.hooks.PSObject.Properties[$eventName]
        $userEntries = if ($userProp) { $userProp.Value } else { $null }
        $merged = Merge-HookEventEntries -UserEntries $userEntries -ToolkitEntries $toolkitEntries
        $before = if ($userEntries) { $userEntries | ConvertTo-Json -Compress -Depth 8 } else { '' }
        $after = if ($merged) { $merged | ConvertTo-Json -Compress -Depth 8 } else { '' }
        if ($before -ne $after) {
            $user.hooks | Add-Member -MemberType NoteProperty -Name $eventName -Value ([object[]]$merged) -Force
            $changed = $true
        }
    }

    $payload = [ordered]@{
        version = $user.version
        hooks   = Get-HooksPayloadHashtable $user.hooks
    }

    return [PSCustomObject]@{
        Changed = $changed
        Payload = $payload
    }
}

function Sync-HooksJson {
    param(
        [string] $RepoRoot,
        [string] $CursorRoot
    )
    $toolkitHooks = Join-Path $RepoRoot 'hooks\hooks.json'
    $destHooks = Join-Path $CursorRoot 'hooks.json'
    if (-not (Test-Path -LiteralPath $toolkitHooks)) {
        return 0
    }

    $result = Merge-HooksJsonContent -ToolkitHooksPath $toolkitHooks -UserHooksPath $destHooks
    $json = ConvertTo-CleanJson $result.Payload
    $existingJson = if (Test-Path -LiteralPath $destHooks) {
        (Get-Content -LiteralPath $destHooks -Raw).Trim()
    }
    else {
        ''
    }

    if ($json.Trim() -eq $existingJson) {
        Write-ToolkitMessage 'hooks.json already up to date.' ([ConsoleColor]::DarkGray)
        return 0
    }

    if ($DryRun) {
        Write-ToolkitMessage "Would merge hooks into: $destHooks" ([ConsoleColor]::Cyan)
        return 1
    }

    Write-Utf8NoBom -Path $destHooks -Content $json
    Write-ToolkitMessage "Merged hooks into: $destHooks" ([ConsoleColor]::Green)
    return 1
}

# ── Main ──────────────────────────────────────────────────────────────────────

$repoRoot = Get-RepoRoot
. (Join-Path $repoRoot 'scripts\_lib\Backup-CursorToolkit.ps1')

$cursorRoot = Join-Path (Get-ToolkitUserHome) '.cursor'
$skillsDest = Join-Path $cursorRoot 'skills'
$rulesDest = Join-Path $cursorRoot 'rules'
$hooksDest = Join-Path $cursorRoot 'hooks'
$sessionsDest = Join-Path $cursorRoot 'sdd\sessions'

Write-ToolkitMessage "Repo : $repoRoot"
Write-ToolkitMessage "Target: $cursorRoot"
if ($DryRun) {
    Write-ToolkitMessage 'Dry run - no files will be written.' ([ConsoleColor]::Yellow)
}

$null = New-CursorToolkitBackup -DryRun:$DryRun

if (-not $DryRun) {
    foreach ($dir in @($cursorRoot, $skillsDest, $rulesDest, $hooksDest, $sessionsDest)) {
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}
elseif (-not (Test-Path -LiteralPath $sessionsDest)) {
    Write-ToolkitMessage "Would create directory: $sessionsDest" ([ConsoleColor]::Cyan)
}

$totalChanges = 0

$agentsSource = Join-Path $repoRoot 'AGENTS.md'
$agentsDest = Join-Path $cursorRoot 'AGENTS.md'
if (Test-Path -LiteralPath $agentsSource) {
    if (Copy-FileIfChanged -SourcePath $agentsSource -DestPath $agentsDest) {
        $totalChanges++
    }
}
else {
    Write-ToolkitMessage 'AGENTS.md not found in repo; skipped.' ([ConsoleColor]::Yellow)
}

$totalChanges += Sync-DirectoryTree `
    -SourceRoot (Join-Path $repoRoot 'skills') `
    -DestRoot $skillsDest

$totalChanges += Sync-Rules -RepoRoot $repoRoot -RulesDest $rulesDest

$totalChanges += Sync-DirectoryTree `
    -SourceRoot (Join-Path $repoRoot 'hooks') `
    -DestRoot $hooksDest `
    -ExcludeFileNames @('hooks.json')

$totalChanges += Sync-HooksJson -RepoRoot $repoRoot -CursorRoot $cursorRoot

$skillsSource = Join-Path $repoRoot 'skills'
$hooksSource = Join-Path $repoRoot 'hooks'
$rulesSource = Join-Path $repoRoot 'rules'

$totalChanges += Remove-StaleSkillDirectories -RepoSkillsRoot $skillsSource -DestSkillsRoot $skillsDest
$totalChanges += Remove-StaleFilesInTree -SourceRoot $skillsSource -DestRoot $skillsDest
$totalChanges += Remove-StaleFilesInTree -SourceRoot $hooksSource -DestRoot $hooksDest -ExcludeFileNames @('hooks.json')
$totalChanges += Remove-StaleRules -RulesSource $rulesSource -RulesDest $rulesDest

Write-Host ''
if ($totalChanges -eq 0) {
    Write-ToolkitMessage 'Deploy complete - already up to date (idempotent).' ([ConsoleColor]::Green)
}
else {
    if ($DryRun) {
        Write-ToolkitMessage "Dry run complete - $totalChanges item(s) would change." ([ConsoleColor]::Cyan)
    }
    else {
        Write-ToolkitMessage "Deploy complete - $totalChanges item(s) updated." ([ConsoleColor]::Green)
        Write-ToolkitMessage 'Restart Cursor or reload hooks if hooks.json changed.' ([ConsoleColor]::DarkGray)
    }
}

Write-Host ''
Write-ToolkitMessage 'Run smoke test: .\scripts\validation\validate-all.ps1' ([ConsoleColor]::DarkGray)

exit 0
