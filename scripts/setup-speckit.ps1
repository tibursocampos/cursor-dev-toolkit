#Requires -Version 5.1
<#
.SYNOPSIS
  Installs Spec Kit prerequisites and initializes global SDD directories for cursor-dev-toolkit.

.EXAMPLE
  .\scripts\setup-speckit.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host 'Setting up GitHub Spec Kit...' -ForegroundColor Cyan

$pythonInstalled = $false
try {
    $pyVersion = & python --version 2>&1
    if ($pyVersion -match 'Python 3\.(1[0-9]|[2-9])') {
        Write-Host "Python detected: $pyVersion" -ForegroundColor Green
        $pythonInstalled = $true
    }
    else {
        Write-Host "Python found but version is below 3.10: $pyVersion" -ForegroundColor Yellow
    }
}
catch {
    Write-Host 'Python not found on PATH.' -ForegroundColor Yellow
}

if (-not $pythonInstalled) {
    $response = Read-Host 'Python 3.10+ not found. Install via winget? (yes / no)'
    if ($response -match '^(yes|sim|y)$') {
        winget install -e --id Python.Python.3.12
        Write-Host 'Restart the terminal and run this script again.' -ForegroundColor Yellow
        exit 0
    }
    Write-Host 'Install Python 3.10+ manually: https://www.python.org/downloads/' -ForegroundColor Red
    exit 1
}

$uvInstalled = $false
try {
    $uvVer = & uv --version 2>&1
    if ($uvVer -match 'uv \d') {
        Write-Host "uv detected: $uvVer" -ForegroundColor Green
        $uvInstalled = $true
    }
}
catch {
    Write-Host 'uv not found.' -ForegroundColor Yellow
}

if (-not $uvInstalled) {
    $response = Read-Host 'Install uv now? (yes / no)'
    if ($response -match '^(yes|sim|y)$') {
        powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
    }
    else {
        Write-Host 'Install uv: powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"' -ForegroundColor Red
        exit 1
    }
}

Write-Host 'Checking specify-cli...'
$specifyInstalled = $false
try {
    $specVer = & specify --version 2>&1
    if ($specVer -match 'specify \d') {
        Write-Host "specify-cli detected: $specVer" -ForegroundColor Green
        $specifyInstalled = $true
    }
}
catch {
    Write-Host 'specify-cli not detected.' -ForegroundColor Yellow
}

if (-not $specifyInstalled) {
    Write-Host 'Installing specify-cli via uv...'
    & uv tool install specify-cli --from git+https://github.com/github/spec-kit.git --force
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'Failed to install specify-cli.' -ForegroundColor Red
        exit 1
    }
    Write-Host 'specify-cli installed.' -ForegroundColor Green
}

$sddPath = Join-Path $env:USERPROFILE '.cursor\sdd'
$sessionsPath = Join-Path $sddPath 'sessions'
$manifestPath = Join-Path $sddPath 'manifest.json'

foreach ($dir in @($sddPath, $sessionsPath)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "Created: $dir"
    }
}

if (-not (Test-Path $manifestPath)) {
    $initial = @{ schema_version = 2; repositories = @{} } | ConvertTo-Json -Depth 5
    $initial | Set-Content -Path $manifestPath -Encoding UTF8
    Write-Host 'Initialized manifest.json (schema v2).'
}

Write-Host ''
Write-Host 'Spec Kit setup complete. Run configure-repo-sdd.ps1 for each repository.' -ForegroundColor Green
exit 0
