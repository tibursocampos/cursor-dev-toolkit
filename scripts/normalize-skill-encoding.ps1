#Requires -Version 5.1
<#
.SYNOPSIS
  Normalizes encoding and punctuation in skill markdown files under skills/.
#>
[CmdletBinding()]
param(
    [string] $SkillsRoot
)

if (-not $SkillsRoot) {
    $scriptDir = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptDir)) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    $SkillsRoot = Join-Path (Split-Path -Parent $scriptDir) 'skills'
}

$roots = @($SkillsRoot)
$repoRoot = Split-Path -Parent $SkillsRoot
foreach ($extra in @('docs', 'rules', 'README.md', 'AGENTS.md')) {
    $path = Join-Path $repoRoot $extra
    if (Test-Path -LiteralPath $path) { $roots += $path }
}

$mdFiles = foreach ($root in $roots) {
    if (Test-Path -LiteralPath $root -PathType Leaf) { Get-Item -LiteralPath $root }
    else { Get-ChildItem -LiteralPath $root -Recurse -Filter '*.md' -ErrorAction SilentlyContinue }
}
$mdFiles += Get-ChildItem -LiteralPath (Join-Path $repoRoot 'rules') -Filter '*.mdc' -ErrorAction SilentlyContinue

$mdFiles | Sort-Object -Property FullName -Unique | ForEach-Object {
    $text = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $normalized = $text
    $normalized = $normalized.Replace([string][char]0x2014, '-')
    $normalized = $normalized.Replace([string][char]0x2013, '-')
    $normalized = $normalized.Replace([string][char]0x2192, '->')
    $normalized = $normalized -replace '\*\*STOP\*\* [^\s]+ ask', '**STOP** - ask'
    $normalized = $normalized -replace '\*\*STOP\*\* session [^\s]+ handoff', '**STOP** session - handoff'
    $normalized = $normalized -replace '^[^\r\n]+ If any unchecked: STOP', '-> If any unchecked: STOP'
    $normalized = $normalized -replace 'Step -1 [^\r\n]+ Gate check', 'Step -1 - Gate check'
    $normalized = $normalized.Replace([string][char]0x00E2 + [char]0x0080 + [char]0x0094, '-')
    $normalized = $normalized.Replace([string][char]0x00E2 + [char]0x0080 + [char]0x0093, '-')
    $normalized = $normalized.Replace([string][char]0x00E2 + [char]0x0086 + [char]0x0092, '->')
    $normalized = $normalized.Replace([string][char]0x00C2 + [char]0x00A7, 'section')
    $normalized = $normalized.Replace([string][char]0x00E2 + [char]0x0089 + [char]0x00A5, '>=')
    $normalized = $normalized.Replace([string][char]0x00E2 + [char]0x0089 + [char]0x00A4, '<=')
    $normalized = $normalized.Replace('ConcluÃ­do', 'Concluido')
    $normalized = $normalized.Replace('ConcluÃ­dos', 'Concluidos')
    $normalized = $normalized.Replace('guardrails.mdc', 'guardrails.mdc')
    $normalized = $normalized.Replace('GUARDRAILS.md', 'guardrails.mdc')
    $normalized = $normalized -replace 'sdd_artifacts', 'sdd-artifacts'
    if ($normalized -ne $text) {
        [System.IO.File]::WriteAllText($_.FullName, $normalized, [System.Text.UTF8Encoding]::new($false))
        Write-Host "Fixed: $($_.Name)"
    }
}
