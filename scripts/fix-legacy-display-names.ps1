#Requires -Version 5.1
<#
.SYNOPSIS
  Replaces legacy skill display names with canonical kebab-case names across the repo.
#>
[CmdletBinding()]
param([string] $RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }

$replacements = [ordered]@{
    'plan-repo-docs'      = 'document-plan'
    'document-repo'       = 'document-implement'
    'dotnet-developer'    = 'developer'
    '02-dotnet-developer' = '02-developer'
    '02 — dotnet-developer' = '02 — developer'
    'SDD implement'       = 'SDD sdd-develop'
    '| `implement` |'      = '| `sdd-develop` |'
    '`implement`'         = '`sdd-develop`'
    'skills/spec/'        = 'skills/sdd-spec/'
    'skills/plan/'        = 'skills/sdd-plan/'
    'skills/implement/'   = 'skills/sdd-develop/'
    'skills/dotnet-developer/' = 'skills/developer/'
    'skills/plan-repo-docs/'   = 'skills/document-plan/'
    'skills/document-repo/'    = 'skills/document-implement/'
    'use skill implement' = 'use skill sdd-develop'
    'use skill dotnet-developer' = 'use skill developer'
    'use skill plan-repo-docs'   = 'use skill document-plan'
    'use skill document-repo'    = 'use skill document-implement'
    'SDD `plan`'          = 'SDD `sdd-plan`'
    'SDD `spec`'          = 'SDD `sdd-spec`'
    'executing SDD `plan`' = 'executing SDD `sdd-plan`'
    'executing SDD `implement`' = 'executing SDD `sdd-develop`'
    'ETAPA 11+'           = 'commit-message-validator step'
}

$exclude = @('fix-legacy-display-names.ps1', 'rename-skill-refs.ps1', 'validate-docs-consistency.ps1')
$files = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Include '*.md','*.ps1' |
    Where-Object { $_.FullName -notmatch '\\\.git\\' -and ($exclude -notcontains $_.Name) }

foreach ($file in $files) {
    $original = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $updated = $original
    foreach ($pair in $replacements.GetEnumerator()) {
        $updated = $updated.Replace($pair.Key, $pair.Value)
    }
    if ($updated -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
        Write-Host "Updated: $($file.FullName.Substring($RepoRoot.Length))" -ForegroundColor Green
    }
}

Write-Host 'Legacy display name fix complete.' -ForegroundColor Cyan
