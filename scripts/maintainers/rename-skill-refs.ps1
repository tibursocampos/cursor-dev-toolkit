#Requires -Version 5.1
<#
.SYNOPSIS
  Bulk-replaces legacy skill names with canonical kebab-case names across the repo.

.DESCRIPTION
  Maps obsolete names to canonical Cursor toolkit skill names.
  Includes legacy SDD renames (spec/plan/implement) and the 2026 ops renames
  (refine-story, split-story-checklist, repair-dotnet-build, ef-add-migration,
  scaffold-message-handler).

  Longer patterns are applied first to avoid partial replacements.

.PARAMETER RepoRoot
  Repository root (defaults to parent of scripts/).

.PARAMETER DryRun
  Report files that would change without writing.

.EXAMPLE
  .\scripts\maintainers\rename-skill-refs.ps1 -DryRun

.EXAMPLE
  .\scripts\maintainers\rename-skill-refs.ps1
#>
[CmdletBinding()]
param(
    [string] $RepoRoot,
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    . (Join-Path (Split-Path -Parent $PSScriptRoot) '_lib\Get-ToolkitRepoRoot.ps1')
    $RepoRoot = Get-ToolkitRepoRoot -FromPath $PSScriptRoot
}

# Order matters: more specific / longer patterns first.
$replacements = [ordered]@{
    'use skill create-message-consumer' = 'use skill scaffold-message-handler'
    'use skill refine-backlog-item'     = 'use skill refine-story'
    'use skill breakdown-tasks'         = 'use skill split-story-checklist'
    'use skill add-migrations'          = 'use skill ef-add-migration'
    'use skill fix-build'               = 'use skill repair-dotnet-build'
    'use skill document-repo'           = 'use skill document-implement'
    'use skill plan-repo-docs'          = 'use skill document-plan'
    'use skill implement'               = 'use skill sdd-develop'
    'use skill plan'                    = 'use skill sdd-plan'
    'use skill spec'                    = 'use skill sdd-spec'
    '/create-message-consumer'          = '/scaffold-message-handler'
    '/refine-backlog-item'              = '/refine-story'
    '/breakdown-tasks'                  = '/split-story-checklist'
    '/add-migrations'                   = '/ef-add-migration'
    '/fix-build'                        = '/repair-dotnet-build'
    '/document-repo'                    = '/document-implement'
    '/plan-repo-docs'                   = '/document-plan'
    '/implement'                        = '/sdd-develop'
    '/plan'                             = '/sdd-plan'
    '/spec'                             = '/sdd-spec'
    'skills/create-message-consumer/'   = 'skills/scaffold-message-handler/'
    'skills/refine-backlog-item/'       = 'skills/refine-story/'
    'skills/breakdown-tasks/'           = 'skills/split-story-checklist/'
    'skills/add-migrations/'            = 'skills/ef-add-migration/'
    'skills/fix-build/'                 = 'skills/repair-dotnet-build/'
    'skills/document-repo/'             = 'skills/document-implement/'
    'skills/plan-repo-docs/'            = 'skills/document-plan/'
    'skills/implement/'                 = 'skills/sdd-develop/'
    'skills/plan/'                      = 'skills/sdd-plan/'
    'skills/spec/'                      = 'skills/sdd-spec/'
    'name: create-message-consumer'     = 'name: scaffold-message-handler'
    'name: refine-backlog-item'         = 'name: refine-story'
    'name: breakdown-tasks'             = 'name: split-story-checklist'
    'name: add-migrations'              = 'name: ef-add-migration'
    'name: fix-build'                   = 'name: repair-dotnet-build'
    'name: document-repo'               = 'name: document-implement'
    'name: plan-repo-docs'              = 'name: document-plan'
    'name: implement'                   = 'name: sdd-develop'
    'name: plan'                        = 'name: sdd-plan'
    'name: spec'                        = 'name: sdd-spec'
    '# Skill: create-message-consumer'  = '# Skill: scaffold-message-handler'
    '# Skill: refine-backlog-item'      = '# Skill: refine-story'
    '# Skill: breakdown-tasks'          = '# Skill: split-story-checklist'
    '# Skill: add-migrations'           = '# Skill: ef-add-migration'
    '# Skill: fix-build'                = '# Skill: repair-dotnet-build'
    '# Skill: document-repo'            = '# Skill: document-implement'
    '# Skill: plan-repo-docs'           = '# Skill: document-plan'
    '# Skill: implement'                = '# Skill: sdd-develop'
    '# Skill: plan'                     = '# Skill: sdd-plan'
    '# Skill: spec'                     = '# Skill: sdd-spec'
    'spec to plan to implement'         = 'sdd-spec to sdd-plan to sdd-develop'
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
