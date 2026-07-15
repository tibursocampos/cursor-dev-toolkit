#Requires -Version 5.1
<#
.SYNOPSIS
  Validates structural integrity of toolkit skills and core artifacts.

.DESCRIPTION
  Called by validate-all.ps1. Checks frontmatter, STOP gate blocks, central
  artifact files under skills/ and rules/, and manifest schema v2 when manifest exists.

.EXAMPLE
  .\scripts\validation\validate-skills-structure.ps1
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

$failures = @()
$skillsRoot = Join-Path $RepoRoot 'skills'
$stopMarker = '## STOP - Read before ANY tool call'
$stepMarker = 'Step -1 - Gate check'

$centralArtifacts = @(
    'rules\guardrails.md',
    'skills\_shared\sdd-artifacts\SESSION.md',
    'skills\_shared\sdd-artifacts\PIPELINE.md',
    'skills\_shared\sdd-artifacts\STORAGE.md',
    'skills\_shared\sdd-artifacts\MEMORY-BANK.md',
    'skills\_shared\SKILL_TEMPLATE.md',
    'skills\_shared\templates\features\FEATURE.md',
    'skills\_shared\templates\features\CONTINUITY.md',
    'skills\_shared\templates\features\TREE.md',
    'skills\_shared\templates\features\story\STORY.md',
    'skills\_shared\templates\memory-bank\project-context.md',
    'skills\_shared\templates\memory-bank\tech-stack.json',
    'skills\_shared\agents\ROSTER.md',
    'skills\_shared\agents\ROUTING.md',
    'skills\_shared\agents\SUBAGENT-MODEL.md',
    'skills\_shared\agents\RECEIPT.md',
    'skills\_shared\caveman\CAVEMAN.md',
    'skills\_shared\caveman\COMPACT.md',
    'scripts\inventory\Invoke-MemoryBankInventory.ps1'
)

foreach ($relative in $centralArtifacts) {
    $path = Join-Path $RepoRoot $relative
    if (-not (Test-Path -LiteralPath $path)) {
        $failures += "Missing central artifact: $relative"
    }
}

$forbiddenSpecKit = @(
    'skills\speckit-setup',
    'skills\speckit-init',
    'skills\speckit-spec',
    'skills\speckit-plan',
    'skills\speckit-develop',
    'scripts\setup-speckit.ps1',
    'scripts\validation\validate-speckit-init.ps1',
    'scripts\maintainers\fix-speckit-refs.ps1',
    'docs\guides\06-speckit-workflow.md'
)
foreach ($relative in $forbiddenSpecKit) {
    $path = Join-Path $RepoRoot $relative
    if (Test-Path -LiteralPath $path) {
        $failures += "Forbidden Spec Kit leftover (must be removed): $relative"
    }
}

$requiredOrchestrationSkills = @(
    'orchestrate-analyze',
    'orchestrate-deliver',
    'orchestrate-develop',
    'memory-bank-init'
)
foreach ($skillName in $requiredOrchestrationSkills) {
    $skillPath = Join-Path $skillsRoot $skillName
    if (-not (Test-Path -LiteralPath (Join-Path $skillPath 'SKILL.md'))) {
        $failures += "Missing required skill: skills/$skillName/SKILL.md"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $skillPath 'reference.md'))) {
        $failures += "Missing required reference: skills/$skillName/reference.md"
    }
}

$rosterPromptFiles = @(
    'repo_analyst.md',
    'architect.md',
    'security.md',
    'database.md',
    'impact.md',
    'risk.md',
    'generate-story.md'
)
$promptsDir = Join-Path $RepoRoot 'skills\_shared\agents\prompts'
foreach ($promptFile in $rosterPromptFiles) {
    $promptPath = Join-Path $promptsDir $promptFile
    if (-not (Test-Path -LiteralPath $promptPath)) {
        $failures += "Missing roster prompt: skills/_shared/agents/prompts/$promptFile"
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
        'sdd-spec', 'sdd-plan', 'sdd-develop',
        'orchestrate-analyze', 'orchestrate-deliver', 'orchestrate-develop',
        'memory-bank-init',
        'code-review', 'test-coverage', 'developer', 'document-plan', 'document-implement'
    )
    if ($dir.Name -in $workflowSkills -and $lineCount -lt 100) {
        Write-Warning "$relativeSkill : workflow skill is only $lineCount lines (soft minimum ~100)"
    }

    # Caveman participation wiring (see _shared/caveman/CAVEMAN.md)
    $cavemanLite = @(
        'sdd-spec', 'sdd-plan', 'orchestrate-analyze', 'orchestrate-deliver',
        'document-plan', 'refine-backlog-item', 'memory-bank-init'
    )
    $cavemanFull = @(
        'sdd-develop', 'orchestrate-develop', 'document-implement', 'breakdown-tasks',
        'code-review', 'developer', 'fix-build', 'test-coverage',
        'dotnet-developer', 'react-developer', 'vue-developer', 'angular-developer',
        'blazor-developer', 'electron-developer', 'javascript-developer', 'python-developer',
        'api-integrate', 'containerize', 'i18n-manager', 'performance-profile', 'refactor'
    )
    $cavemanNever = @('commit', 'push')
    if ($dir.Name -in $cavemanNever) {
        if ($content -notmatch '(?m)^\*\*NEVER\*\*') {
            $failures += "$relativeSkill : Caveman NEVER skills must declare **NEVER**"
        }
    }
    elseif ($dir.Name -in $cavemanLite -or $dir.Name -in $cavemanFull) {
        if ($content -notmatch 'Step -1b - Caveman Mode') {
            $failures += "$relativeSkill : missing Step -1b - Caveman Mode block"
        }
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
