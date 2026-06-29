#Requires -Version 5.1
function Get-ToolkitRepoRoot {
    [CmdletBinding()]
    param(
        [string] $FromPath = $PSScriptRoot
    )

    if ([string]::IsNullOrWhiteSpace($FromPath)) {
        throw 'FromPath is required.'
    }

    $candidate = $FromPath
    while ($true) {
        $skillsPath = Join-Path $candidate 'skills'
        $agentsPath = Join-Path $candidate 'AGENTS.md'
        if ((Test-Path -LiteralPath $skillsPath) -and (Test-Path -LiteralPath $agentsPath)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }

        $parent = Split-Path -Parent $candidate
        if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $candidate) {
            break
        }

        $candidate = $parent
    }

    throw "Toolkit repo root not found from path: $FromPath"
}

function Import-ToolkitPathLib {
    param([string] $ScriptRoot = $PSScriptRoot)

    $libPath = Join-Path (Split-Path -Parent $ScriptRoot) '_lib\Get-ToolkitRepoRoot.ps1'
    if (-not (Test-Path -LiteralPath $libPath)) {
        throw "Toolkit path lib not found: $libPath"
    }

    . $libPath
}
