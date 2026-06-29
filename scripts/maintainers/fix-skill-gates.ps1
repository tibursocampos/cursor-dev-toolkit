#Requires -Version 5.1
<#
.SYNOPSIS
  Removes duplicate STOP gate blocks in SKILL.md files.
#>
[CmdletBinding()]
param(
    [string] $SkillsRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $SkillsRoot) {
    . (Join-Path (Split-Path -Parent $PSScriptRoot) '_lib\Get-ToolkitRepoRoot.ps1')
    $repoRoot = Get-ToolkitRepoRoot -FromPath $PSScriptRoot
    $SkillsRoot = Join-Path $repoRoot 'skills'
}

$marker = '## STOP - Read before ANY tool call'

Get-ChildItem -LiteralPath $SkillsRoot -Recurse -Filter 'SKILL.md' | ForEach-Object {
    $raw = [System.IO.File]::ReadAllText($_.FullName)
    $matches = [regex]::Matches($raw, '## STOP')
    if ($matches.Count -le 1) {
        return
    }

    if ($raw -notmatch '(?s)^(---\r?\n.*?\r?\n---\r?\n)(.*)$') {
        Write-Warning "Could not parse frontmatter: $($_.FullName)"
        return
    }

    $frontmatter = $Matches[1]
    $body = $Matches[2]

    $gateEnd = $body.IndexOf('---', [StringComparison]::Ordinal)
    if ($gateEnd -lt 0) {
        Write-Warning "Could not find gate end: $($_.FullName)"
        return
    }

    $firstGateBlock = $body.Substring(0, $gateEnd + 3)
    $remaining = $body.Substring($gateEnd + 3)

    $secondStop = $remaining.IndexOf('## STOP', [StringComparison]::Ordinal)
    if ($secondStop -ge 0) {
        $afterSecond = $remaining.Substring($secondStop)
        $secondEnd = $afterSecond.IndexOf('---', [StringComparison]::Ordinal)
        if ($secondEnd -ge 0) {
            $remaining = $remaining.Substring(0, $secondStop) + $afterSecond.Substring($secondEnd + 3)
        }
    }

    $firstGateBlock = [regex]::Replace($firstGateBlock, '## STOP[^\r\n]* Read before ANY tool call', $marker, 1)
    $fixed = $frontmatter + $firstGateBlock.TrimEnd() + "`r`n`r`n" + $remaining.TrimStart()
    $fixed = [regex]::Replace($fixed, '(?m)^---\r?\n\r?\n---\r?\n\r?\n', "---`r`n`r`n")

    [System.IO.File]::WriteAllText($_.FullName, $fixed, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Deduped: $($_.FullName)"
}
