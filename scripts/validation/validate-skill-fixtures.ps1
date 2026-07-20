#Requires -Version 5.1
<#
.SYNOPSIS
  Golden markers: each fixtures/<skill>/expected-markers.txt line must appear in SKILL.md or reference.md.
#>
[CmdletBinding()]
param(
    [string] $RepoRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    . (Join-Path (Split-Path -Parent $PSScriptRoot) '_lib\Get-ToolkitRepoRoot.ps1')
    $RepoRoot = Get-ToolkitRepoRoot -FromPath $PSScriptRoot
}

$fixturesRoot = Join-Path $PSScriptRoot 'fixtures'
$skillsRoot = Join-Path $RepoRoot 'skills'
$failures = @()

if (-not (Test-Path -LiteralPath $fixturesRoot)) {
    Write-Host 'No fixtures directory; skipping.' -ForegroundColor Yellow
    exit 0
}

Get-ChildItem -LiteralPath $fixturesRoot -Directory | ForEach-Object {
    $skill = $_.Name
    $markersFile = Join-Path $_.FullName 'expected-markers.txt'
    if (-not (Test-Path -LiteralPath $markersFile)) {
        $failures += "fixtures/${skill}: missing expected-markers.txt"
        return
    }

    $skillDir = Join-Path $skillsRoot $skill
    if (-not (Test-Path -LiteralPath $skillDir)) {
        $failures += "fixtures/${skill}: skill folder missing on disk"
        return
    }

    $blob = ''
    foreach ($name in @('SKILL.md', 'reference.md')) {
        $p = Join-Path $skillDir $name
        if (Test-Path -LiteralPath $p) {
            $blob += "`n" + (Get-Content -LiteralPath $p -Raw)
        }
    }

    Get-Content -LiteralPath $markersFile | ForEach-Object {
        $line = $_.Trim()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) { return }
        if ($blob -notmatch [regex]::Escape($line)) {
            $failures += "fixtures/${skill}: missing marker '$line'"
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Skill fixtures validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'Skill fixtures validation passed.' -ForegroundColor Green
exit 0
