#Requires -Version 5.1
<#
.SYNOPSIS
  Registers a repository for Classic SDD in manifest.json (schema v2).

.PARAMETER StorageMode
  global or repository

.PARAMETER RepoPath
  Repository path (defaults to current location).

.EXAMPLE
  .\scripts\configure-repo-sdd.ps1 -StorageMode global -RepoPath "D:\Source\Repos\MyApp"
#>
[CmdletBinding()]
param(
    [ValidateSet('global', 'repository')]
    [string] $StorageMode = 'global',
    [string] $RepoPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sddPath = Join-Path $env:USERPROFILE '.cursor\sdd'
$manifestPath = Join-Path $sddPath 'manifest.json'
$sessionsPath = Join-Path $sddPath 'sessions'

if (-not (Test-Path -LiteralPath $sddPath)) {
    New-Item -ItemType Directory -Path $sddPath -Force | Out-Null
}

if (-not (Test-Path -LiteralPath $sessionsPath)) {
    New-Item -ItemType Directory -Path $sessionsPath -Force | Out-Null
}

if (-not (Test-Path -LiteralPath $manifestPath)) {
    $seed = [PSCustomObject]@{
        schema_version = 2
        repositories   = [PSCustomObject]@{}
    }
    $seed | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Encoding UTF8
    Write-Host 'Created empty manifest.json (schema v2).' -ForegroundColor Cyan
}

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
if (-not $manifest.schema_version) {
    $manifest | Add-Member -NotePropertyName 'schema_version' -NotePropertyValue 2 -Force
}
if (-not $manifest.repositories) {
    $manifest.repositories = [PSCustomObject]@{}
}

$cwd = $RepoPath.Replace('\', '/').TrimEnd('/')
$repoName = Split-Path $RepoPath -Leaf
$targetPath = if ($StorageMode -eq 'global') {
    (Join-Path $sddPath $repoName).Replace('\', '/')
} else {
    $cwd
}

if ($StorageMode -eq 'global' -and -not (Test-Path -LiteralPath $targetPath)) {
    New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
}

$entry = @{
    classic = @{
        storage_mode = $StorageMode
        path         = $targetPath
    }
}

$manifest.repositories | Add-Member -MemberType NoteProperty -Name $cwd -Value $entry -Force
$manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Host "Repository configured in manifest.json (classic only, schema v2)." -ForegroundColor Green
Write-Host "  cwd:  $cwd" -ForegroundColor DarkGray
Write-Host "  mode: $StorageMode" -ForegroundColor DarkGray
Write-Host "  path: $targetPath" -ForegroundColor DarkGray
Write-Host 'Legacy speckit keys in other entries are ignored if present.' -ForegroundColor DarkGray
exit 0
