#Requires -Version 5.1
<#
.SYNOPSIS
  Configures Spec Kit for a repository in manifest.json (schema v2) and runs specify init.

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

Write-Host 'Checking specify-cli...' -ForegroundColor Cyan
try {
    $specVer = & specify --version 2>&1
    if ($specVer -notmatch 'specify \d') {
        Write-Host 'Spec Kit CLI did not respond correctly.' -ForegroundColor Red
        exit 1
    }
    Write-Host "specify-cli detected: $specVer" -ForegroundColor Green
}
catch {
    Write-Host 'Error: specify-cli not found. Run setup-speckit.ps1 first and restart the terminal.' -ForegroundColor Red
    exit 1
}

$sddPath = Join-Path $env:USERPROFILE '.cursor\sdd'
$manifestPath = Join-Path $sddPath 'manifest.json'
$sessionsPath = Join-Path $sddPath 'sessions'

if (-not (Test-Path $manifestPath)) {
    Write-Host 'Error: manifest.json missing. Run setup-speckit.ps1 first.' -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $sessionsPath)) {
    New-Item -ItemType Directory -Path $sessionsPath -Force | Out-Null
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

$entry = @{
    classic = @{
        storage_mode = $StorageMode
        path         = $targetPath
    }
    speckit = @{
        storage_mode      = $StorageMode
        path              = $targetPath
        initialized       = $false
        init_validated_at = $null
    }
}

$manifest.repositories | Add-Member -MemberType NoteProperty -Name $cwd -Value $entry -Force
$manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Encoding UTF8
Write-Host 'Repository configured in manifest.json (schema v2)!' -ForegroundColor Green

$specifyFolderPath = Join-Path $targetPath '.specify'
if (Test-Path -LiteralPath $specifyFolderPath) {
    Write-Host ".specify/ already exists at '$targetPath'. Running validation only." -ForegroundColor Yellow
}
else {
    $parentDir = Split-Path $targetPath -Parent
    if ($StorageMode -eq 'global' -and -not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
    }

    Write-Host "Initializing Spec Kit at: $targetPath" -ForegroundColor Cyan
    if ($StorageMode -eq 'global') {
        & specify init $targetPath --integration generic --integration-options='--commands-dir .specify/commands/' --force
    }
    else {
        Push-Location $RepoPath
        try {
            & specify init . --integration generic --integration-options='--commands-dir .specify/commands/' --force
        }
        finally {
            Pop-Location
        }
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host 'Error: specify init failed.' -ForegroundColor Red
        exit 1
    }
}

$validateScript = Join-Path $PSScriptRoot 'validate-speckit-init.ps1'
& $validateScript -RepoPath $RepoPath -SpecifyRoot $targetPath
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Spec Kit validation failed after init.' -ForegroundColor Red
    exit 1
}

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$manifest.repositories.$cwd.speckit.initialized = $true
$manifest.repositories.$cwd.speckit.init_validated_at = [datetime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
$manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Host "Spec Kit ready at '$targetPath'." -ForegroundColor Green
exit 0
