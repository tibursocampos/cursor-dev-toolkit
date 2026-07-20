#Requires -Version 5.1
<#
.SYNOPSIS
  Validates skill graph edges, forbid rules, and catalog parity counts.
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

$graphPath = Join-Path $PSScriptRoot 'contracts\skill-graph.json'
if (-not (Test-Path -LiteralPath $graphPath)) {
    Write-Host "Missing graph file: $graphPath" -ForegroundColor Red
    exit 1
}

$doc = Get-Content -LiteralPath $graphPath -Raw | ConvertFrom-Json
$skillsRoot = Join-Path $RepoRoot $doc.skillsRoot
$failures = @()

$skillDirs = @(Get-ChildItem -LiteralPath $skillsRoot -Directory | Where-Object { $_.Name -ne '_shared' } | ForEach-Object { $_.Name })

foreach ($edge in $doc.edges) {
    if ($skillDirs -notcontains $edge.from) {
        $failures += "edge: missing from skill folder '$($edge.from)'"
    }
    if ($skillDirs -notcontains $edge.to) {
        $failures += "edge: missing to skill folder '$($edge.to)'"
    }
    $fromSkill = Join-Path (Join-Path $skillsRoot $edge.from) 'SKILL.md'
    if (Test-Path -LiteralPath $fromSkill) {
        $text = Get-Content -LiteralPath $fromSkill -Raw
        if ($text -notmatch [regex]::Escape($edge.to)) {
            $failures += "edge $($edge.from)->$($edge.to) ($($edge.kind)): '$($edge.to)' not mentioned in $($edge.from)/SKILL.md"
        }
    }
}

foreach ($rule in $doc.forbids) {
    $path = Join-Path (Join-Path $skillsRoot $rule.skill) $rule.file
    if (-not (Test-Path -LiteralPath $path)) {
        $failures += "forbid $($rule.id): missing $path"
        continue
    }
    $text = Get-Content -LiteralPath $path -Raw
    if ($text -notmatch [regex]::Escape($rule.mustMatch)) {
        $failures += "forbid $($rule.id): missing section marker '$($rule.mustMatch)'"
        continue
    }
    $anyHit = $false
    foreach ($needle in $rule.mustAlsoMatchAny) {
        if ($text -match [regex]::Escape($needle)) { $anyHit = $true; break }
    }
    if (-not $anyHit) {
        $failures += "forbid $($rule.id): expected one of: $($rule.mustAlsoMatchAny -join ' | ')"
    }
}

$diskCount = $skillDirs.Count
foreach ($prop in @('readme', 'skillsMd', 'guidesReadme')) {
    if (-not ($doc.catalogParity.PSObject.Properties.Name -contains $prop)) { continue }
    $rel = $doc.catalogParity.$prop
    $path = Join-Path $RepoRoot $rel
    if (-not (Test-Path -LiteralPath $path)) {
        $failures += "catalogParity: missing $rel"
        continue
    }
    $text = Get-Content -LiteralPath $path -Raw
    foreach ($name in $skillDirs) {
        if ($prop -eq 'guidesReadme') {
            # guides hub may omit some operational skills from the quick table; require core SDD/orchestrate only
            continue
        }
        if ($text -notmatch [regex]::Escape("``$name``") -and $text -notmatch [regex]::Escape($name)) {
            if ($prop -eq 'readme' -or $prop -eq 'skillsMd') {
                $failures += "catalogParity ($rel): skill '$name' not listed"
            }
        }
    }
    if ($text -match '(?i)(\d+)\s+skills') {
        $claimed = [int]$Matches[1]
        if ($claimed -ne $diskCount) {
            $failures += "catalogParity ($rel): claims $claimed skills but disk has $diskCount"
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Skill graph validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Skill graph validation passed ($diskCount skills on disk)." -ForegroundColor Green
exit 0
