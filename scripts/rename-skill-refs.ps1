#Requires -Version 5.1
<#
.SYNOPSIS
  Bulk-replaces legacy skill names with canonical kebab-case names across the repo.

.DESCRIPTION
  Maps obsolete names to canonical Cursor toolkit skill names:
  spec -> sdd-spec, plan -> sdd-plan, implement -> sdd-develop,
  dotnet-developer -> developer, plan-repo-docs -> document-plan,
  document-repo -> document-implement.

  Longer patterns are applied first to avoid partial replacements.

.PARAMETER RepoRoot
  Repository root (defaults to parent of scripts/).

.PARAMETER DryRun
  Report files that would change without writing.

.EXAMPLE
  .\scripts\rename-skill-refs.ps1 -DryRun

.EXAMPLE
  .\scripts\rename-skill-refs.ps1
#>
[CmdletBinding()]
param(
    [string] $RepoRoot,
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    $scriptDir = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptDir)) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    $RepoRoot = Split-Path -Parent $scriptDir
}

# Order matters: more specific / longer patterns first.
$replacements = [ordered]@{
    'use skill document-repo'     = 'use skill document-implement'
    'use skill plan-repo-docs'    = 'use skill document-plan'
    'use skill dotnet-developer'  = 'use skill developer'
    'use skill implement'         = 'use skill sdd-develop'
    'use skill plan'              = 'use skill sdd-plan'
    'use skill spec'              = 'use skill sdd-spec'
    '/document-repo'              = '/document-implement'
    '/plan-repo-docs'             = '/document-plan'
    '/dotnet-developer'           = '/developer'
    '/implement'                  = '/sdd-develop'
    '/plan'                       = '/sdd-plan'
    '/spec'                       = '/sdd-spec'
    'skills/document-repo/'       = 'skills/document-implement/'
    'skills/plan-repo-docs/'      = 'skills/document-plan/'
    'skills/dotnet-developer/'    = 'skills/developer/'
    'skills/implement/'           = 'skills/sdd-develop/'
    'skills/plan/'                = 'skills/sdd-plan/'
    'skills/spec/'                = 'skills/sdd-spec/'
    'name: document-repo'         = 'name: document-implement'
    'name: plan-repo-docs'        = 'name: document-plan'
    'name: dotnet-developer'      = 'name: developer'
    'name: implement'             = 'name: sdd-develop'
    'name: plan'                  = 'name: sdd-plan'
    'name: spec'                  = 'name: sdd-spec'
    '# Skill: document-repo'      = '# Skill: document-implement'
    '# Skill: plan-repo-docs'     = '# Skill: document-plan'
    '# Skill: dotnet-developer'   = '# Skill: developer'
    '# Skill: implement'          = '# Skill: sdd-develop'
    '# Skill: plan'               = '# Skill: sdd-plan'
    '# Skill: spec'               = '# Skill: sdd-spec'
    'sdd-spec -> sdd-plan -> sdd-develop'   = 'sdd-spec -> sdd-plan -> sdd-develop'
    'spec to plan to implement'   = 'sdd-spec to sdd-plan to sdd-develop'
}

$excludeDirs = @('.git', 'node_modules', 'bin', 'obj')
$extensions = @('*.md', '*.ps1', '*.json', '*.mdc')

$files = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Include $extensions |
    Where-Object {
        $parts = $_.FullName.Substring($RepoRoot.Length).Split([char[]]@('\', '/'), [StringSplitOptions]::RemoveEmptyEntries)
        -not ($parts | Where-Object { $excludeDirs -contains $_ })
    }

$changedCount = 0
foreach ($file in $files) {
    if ($file.Name -eq 'rename-skill-refs.ps1') { continue }

    $original = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $updated = $original

    foreach ($pair in $replacements.GetEnumerator()) {
        $updated = $updated.Replace($pair.Key, $pair.Value)
    }

    if ($updated -eq $original) { continue }

    $relative = $file.FullName.Substring($RepoRoot.Length).TrimStart('\', '/')
    if ($DryRun) {
        Write-Host "Would update: $relative" -ForegroundColor Cyan
    }
    else {
        [System.IO.File]::WriteAllText($file.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
        Write-Host "Updated: $relative" -ForegroundColor Green
    }
    $changedCount++
}

if ($DryRun) {
    Write-Host "$changedCount file(s) would be updated." -ForegroundColor Cyan
}
else {
    Write-Host "$changedCount file(s) updated." -ForegroundColor Green
}
