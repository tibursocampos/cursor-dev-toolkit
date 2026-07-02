#Requires -Version 5.1
<#
.SYNOPSIS
  Syncs Impeccable reference/*.md from upstream pbakaus/impeccable into the toolkit skill.

.DESCRIPTION
  Copies command references from the local impeccable clone (default tag skill-v3.9.1).
  Does not copy live scripts, detector bundle, or SKILL.src.md — adapt router manually after sync.

.PARAMETER SourcePath
  Path to impeccable repo root. Default: D:\Source\Repos\impeccable

.PARAMETER Tag
  Optional git tag to checkout before copy.

.PARAMETER ReferenceNames
  Specific reference files to copy. Default: all *.md in upstream reference/ except preserved toolkit files.

.EXAMPLE
  .\scripts\maintainers\sync-impeccable-refs.ps1

.EXAMPLE
  .\scripts\maintainers\sync-impeccable-refs.ps1 -SourcePath D:\Source\Repos\impeccable -Tag skill-v3.9.1
#>
[CmdletBinding()]
param(
    [string] $SourcePath = 'D:\Source\Repos\impeccable',
    [string] $Tag = '',
    [string[]] $ReferenceNames = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path -Parent $PSScriptRoot) '_lib\Get-ToolkitRepoRoot.ps1')
$repoRoot = Get-ToolkitRepoRoot -FromPath $PSScriptRoot

$upstreamRef = Join-Path $SourcePath '.cursor\skills\impeccable\reference'
$destRef = Join-Path $repoRoot 'skills\impeccable\reference'

if (-not (Test-Path -LiteralPath $upstreamRef)) {
    Write-Error "Upstream reference path not found: $upstreamRef"
}

if ($Tag) {
    Push-Location $SourcePath
    try {
        git fetch --tags 2>$null
        git checkout $Tag
        if ($LASTEXITCODE -ne 0) { throw "git checkout $Tag failed" }
        Write-Host "Checked out tag: $Tag" -ForegroundColor Cyan
    }
    finally {
        Pop-Location
    }
}

$preserve = @('DESIGN-BRIEF-TEMPLATE.md')

if ($ReferenceNames.Count -gt 0) {
    $files = $ReferenceNames
}
else {
    $files = Get-ChildItem -LiteralPath $upstreamRef -Filter '*.md' |
        Where-Object { $preserve -notcontains $_.Name } |
        ForEach-Object { $_.Name }
}

New-Item -ItemType Directory -Force -Path $destRef | Out-Null

$copied = 0
foreach ($name in $files) {
    $src = Join-Path $upstreamRef $name
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "Skip missing upstream file: $name"
        continue
    }
    Copy-Item -LiteralPath $src -Destination (Join-Path $destRef $name) -Force
    $copied++
}

Write-Host "Synced $copied reference file(s) to skills/impeccable/reference/" -ForegroundColor Green
Write-Host "Preserved toolkit files: $($preserve -join ', ')" -ForegroundColor DarkGray
Write-Host "Review skills/impeccable/SKILL.md if router or command table changed upstream." -ForegroundColor Yellow
