#Requires -Version 5.1
<#
.SYNOPSIS
  Validates SKILL.md files use English instructional body (heuristic).

.DESCRIPTION
  Called by validate-all.ps1. Fails if common Portuguese process headings appear outside (pt-BR) blocks.
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

$portuguesePatterns = @(
    'Carregar ',
    'Aguardar respostas',
    'Confirmar antes de gravar',
    'Passo -1\. Pipeline',
    'Router central do toolkit',
    'Gestão de Contexto',
    'Convenções Git',
    'Não encontrei um PRD'
)

$failures = @()
Get-ChildItem -LiteralPath $SkillsRoot -Recurse -Filter 'SKILL.md' | ForEach-Object {
    $lines = Get-Content -LiteralPath $_.FullName
    $relative = $_.FullName.Substring($SkillsRoot.Length).TrimStart('\', '/')
    foreach ($pattern in $portuguesePatterns) {
        if ($lines -match $pattern) {
            $failures += "$relative : matched '$pattern'"
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Skills English validation FAILED:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host 'Skills English validation passed (heuristic).' -ForegroundColor Green
exit 0
