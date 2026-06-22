#Requires -Version 5.1
<#
.SYNOPSIS
  Validates structural integrity of toolkit skills and core artifacts.

.DESCRIPTION
  Called by validate-all.ps1. Checks frontmatter, STOP gate blocks, central
  artifact files under skills/ and rules/, and manifest schema v2 when manifest exists.

.EXAMPLE
  .\scripts\validate-skills-structure.ps1
#>
[CmdletBinding()]
param(
    [string] $RepoRoot
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

$failures = @()
$skillsRoot = Join-Path $RepoRoot 'skills'
$stopMarker = '## STOP - Read before ANY tool call'
$stepMarker = 'Step -1 - Gate check'

$centralArtifacts = @(
    'rules\guardrails.md',
    'skills\_shared\sdd-artifacts\SESSION.md',
    'skills\_shared\sdd-artifacts\PIPELINE.md',
    'skills\_shared\sdd-artifacts\STORAGE.md',
    'skills\_shared\SKILL_TEMPLATE.md'
)

foreach ($relative in $centralArtifacts) {
    $path = Join-Path $RepoRoot $relative
    if (-not (Test-Path -LiteralPath $path)) {
        $failures += "Missing central artifact: $relative"
    }
}

$skillDirs = Get-ChildItem -LiteralPath $skillsRoot -Directory | Where-Object { $_.Name -ne '_shared' }
foreach ($dir in $skillDirs) {
    $skillPath = Join-Path $dir.FullName 'SKILL.md'
    $relativeSkill = $skillPath.Substring($RepoRoot.Length).TrimStart('\', '/')

    if (-not (Test-Path -LiteralPath $skillPath)) {
        $failures += "$relativeSkill : SKILL.md missing"
        continue
    }

    $content = Get-Content -LiteralPath $skillPath -Raw

    if ($content -notmatch '(?s)^---\r?\n.*?\r?\n---\r?\n') {
        $failures += "$relativeSkill : missing YAML frontmatter"
        continue
    }

    if ($content -notmatch '(?m)^description:\s*') {
        $failures += "$relativeSkill : missing frontmatter description"
    }

    $stopCount = ([regex]::Matches($content, [regex]::Escape($stopMarker))).Count
    if ($stopCount -eq 0) {
        $failures += "$relativeSkill : missing STOP gate block"
    }
    elseif ($stopCount -gt 1) {
        $failures += "$relativeSkill : duplicate STOP gate block ($stopCount occurrences of '$stopMarker')"
    }

    if ($content -notmatch [regex]::Escape($stepMarker)) {
        $failures += "$relativeSkill : missing '$stepMarker'"
    }

    $lineCount = @(Get-Content -LiteralPath $skillPath).Count
    if ($lineCount -gt 500) {
        $failures += "$relativeSkill : SKILL.md exceeds 500 lines ($lineCount)"
    }
    elseif ($lineCount -gt 350) {
        Write-Warning "$relativeSkill : SKILL.md is $lineCount lines (consider progressive disclosure; warn threshold 350)"
    }

    $workflowSkills = @(
        'speckit-plan', 'speckit-spec', 'speckit-develop', 'sdd-spec', 'sdd-plan', 'sdd-develop',
        'code-review', 'test-coverage', 'developer', 'document-plan', 'document-implement'
    )
    if ($dir.Name -in $workflowSkills -and $lineCount -lt 100) {
        Write-Warning "$relativeSkill : workflow skill is only $lineCount lines (soft minimum ~100)"
    }
}

$manifestPath = Join-Path $env:USERPROFILE '.cursor\sdd\manifest.json'
if (Test-Path -LiteralPath $manifestPath) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

    if ($manifest.PSObject.Properties.Name -notcontains 'schema_version') {
        Write-Warning 'manifest.json uses legacy format (no schema_version). Re-run configure-repo-sdd.ps1 to migrate to v2.'
    }
    else {
        if ([int]$manifest.schema_version -ne 2) {
            $failures += "manifest.json : schema_version must be 2 (found $($manifest.schema_version))"
        }

        if ($manifest.repositories) {
            foreach ($repoKey in $manifest.repositories.PSObject.Properties.Name) {
                $entry = $manifest.repositories.$repoKey
                if ($entry.PSObject.Properties.Name -notcontains 'classic') {
                    $failures += "manifest.json : repository '$repoKey' missing classic section"
                }
                if ($entry.PSObject.Properties.Name -notcontains 'speckit') {
                    $failures += "manifest.json : repository '$repoKey' missing speckit section"
                }
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Skills structure validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'Skills structure validation passed.' -ForegroundColor Green
exit 0
