#Requires -Version 5.1
<#
.SYNOPSIS
  Validates skill contract markers declared in skill-contracts.json.
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

$contractsPath = Join-Path $PSScriptRoot 'contracts\skill-contracts.json'
if (-not (Test-Path -LiteralPath $contractsPath)) {
    Write-Host "Missing contracts file: $contractsPath" -ForegroundColor Red
    exit 1
}

$doc = Get-Content -LiteralPath $contractsPath -Raw | ConvertFrom-Json
$skillsRoot = Join-Path $RepoRoot $doc.skillsRoot
$failures = @()

foreach ($c in $doc.contracts) {
    foreach ($fileName in $c.files) {
        $path = Join-Path (Join-Path $skillsRoot $c.skill) $fileName
        if (-not (Test-Path -LiteralPath $path)) {
            $failures += "$($c.id): missing file $path"
            continue
        }
        $text = Get-Content -LiteralPath $path -Raw
        if ($c.PSObject.Properties.Name -contains 'mustContain' -and $c.mustContain) {
            foreach ($needle in $c.mustContain) {
                if ($text -notmatch [regex]::Escape($needle)) {
                    $failures += "$($c.id): $($c.skill)/$fileName missing required marker '$needle'"
                }
            }
        }
        if ($c.PSObject.Properties.Name -contains 'mustContainAny' -and $c.mustContainAny) {
            $anyHit = $false
            foreach ($needle in $c.mustContainAny) {
                if ($text -match [regex]::Escape($needle)) { $anyHit = $true; break }
            }
            if (-not $anyHit) {
                $failures += "$($c.id): $($c.skill)/$fileName missing any of: $($c.mustContainAny -join ' | ')"
            }
        }
        if ($c.PSObject.Properties.Name -contains 'mustNotContain' -and $c.mustNotContain) {
            foreach ($needle in $c.mustNotContain) {
                if ($text.Contains($needle)) {
                    $failures += "$($c.id): $($c.skill)/$fileName contains forbidden '$needle'"
                }
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Skill contracts validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'Skill contracts validation passed.' -ForegroundColor Green
exit 0
