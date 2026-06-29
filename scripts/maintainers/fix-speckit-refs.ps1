#Requires -Version 5.1
<#
.SYNOPSIS
  Reverts over-aggressive speckit renames from rename-skill-refs.ps1.
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

$replacements = [ordered]@{
    'sdd-speckit-develop'     = 'speckit-develop'
    'sdd-speckit-setup'       = 'speckit-setup'
    'sdd-speckit-init'        = 'speckit-init'
    'sdd-speckit-spec'        = 'speckit-spec'
    'sdd-speckit-plan'        = 'speckit-plan'
    '.specify/sdd-specs/'     = '.specify/specs/'
    '/sdd-spec.md'            = '/spec.md'
    '/sdd-plan.md'            = '/plan.md'
    'SDD/sdd-speckit'         = 'SDD/speckit'
    'name: sdd-speckit-'      = 'name: speckit-'
    '# Skill: sdd-speckit-'   = '# Skill: speckit-'
}

$extensions = @('*.md', '*.ps1', '*.json')
$files = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Include $extensions |
    Where-Object { $_.FullName -notmatch '\\\.git\\' }

foreach ($file in $files) {
    if ($file.Name -in @('rename-skill-refs.ps1', 'fix-speckit-refs.ps1')) { continue }
    $original = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $updated = $original
    foreach ($pair in $replacements.GetEnumerator()) {
        $updated = $updated.Replace($pair.Key, $pair.Value)
    }
    if ($updated -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
        Write-Host "Fixed: $($file.FullName.Substring($RepoRoot.Length))" -ForegroundColor Green
    }
}

Write-Host 'Speckit reference fix complete.' -ForegroundColor Cyan
