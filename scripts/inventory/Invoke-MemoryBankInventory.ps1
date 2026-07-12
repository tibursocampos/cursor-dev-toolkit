#Requires -Version 5.1
<#
.SYNOPSIS
  Read-only inventory of a consumer repo into memory-bank/.inventory/.

.DESCRIPTION
  Scans manifests, lockfiles, and common entry points. Writes only under
  memory-bank/.inventory/ (sources.json, gaps.md stubs, refresh-history.jsonl).
  Does not modify application source. No Python/uv/specify dependency.

.PARAMETER RepoPath
  Consumer repository root (default: current location).

.PARAMETER BankPath
  Override memory-bank root (default: <RepoPath>/memory-bank).

.PARAMETER StaleDays
  Age threshold recorded in sources.json (default: 90).

.PARAMETER DryRun
  Print planned writes without creating files.

.PARAMETER AllowCreateInventory
  Create memory-bank/.inventory/ when missing (required for first write).

.EXAMPLE
  .\scripts\inventory\Invoke-MemoryBankInventory.ps1 -RepoPath "D:\Source\Repos\MyApp" -AllowCreateInventory
#>
[CmdletBinding()]
param(
    [string] $RepoPath = (Get-Location).Path,
    [string] $BankPath,
    [int] $StaleDays = 90,
    [switch] $DryRun,
    [switch] $AllowCreateInventory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-NormalizedPath {
    param([string] $Path)
    return ([IO.Path]::GetFullPath($Path)).Replace('\', '/').TrimEnd('/')
}

function Test-IsUnderRoot {
    param(
        [string] $Candidate,
        [string] $Root
    )
    $c = (Get-NormalizedPath $Candidate) + '/'
    $r = (Get-NormalizedPath $Root) + '/'
    return $c.StartsWith($r, [StringComparison]::OrdinalIgnoreCase)
}

function Find-FilesByName {
    param(
        [string] $Root,
        [string[]] $Names,
        [int] $MaxDepth = 4
    )
    $results = @()
    $nameSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($n in $Names) { [void]$nameSet.Add($n) }

    $excludeDirs = @(
        '.git', 'node_modules', 'bin', 'obj', 'dist', 'build', '.vs',
        '.inventory', 'memory-bank', 'TestResults', 'coverage', '.turbo',
        '.next', 'vendor'
    )

    $stack = New-Object System.Collections.Generic.Stack[object]
    $stack.Push([PSCustomObject]@{ Path = $Root; Depth = 0 })

    while ($stack.Count -gt 0) {
        $frame = $stack.Pop()
        if ($frame.Depth -gt $MaxDepth) { continue }

        try {
            $entries = Get-ChildItem -LiteralPath $frame.Path -Force -ErrorAction Stop
        }
        catch {
            continue
        }

        foreach ($entry in $entries) {
            if ($entry.PSIsContainer) {
                if ($excludeDirs -contains $entry.Name) { continue }
                if ($frame.Depth -lt $MaxDepth) {
                    $stack.Push([PSCustomObject]@{ Path = $entry.FullName; Depth = $frame.Depth + 1 })
                }
                continue
            }

            if ($nameSet.Contains($entry.Name)) {
                $results += $entry
            }
        }
    }

    return $results
}

function Find-FilesByExtension {
    param(
        [string] $Root,
        [string[]] $Extensions,
        [int] $MaxDepth = 3
    )
    $results = @()
    $extSet = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($e in $Extensions) { [void]$extSet.Add($e) }

    $excludeDirs = @(
        '.git', 'node_modules', 'bin', 'obj', 'dist', 'build', '.vs',
        '.inventory', 'memory-bank', 'TestResults', 'coverage'
    )

    $stack = New-Object System.Collections.Generic.Stack[object]
    $stack.Push([PSCustomObject]@{ Path = $Root; Depth = 0 })

    while ($stack.Count -gt 0) {
        $frame = $stack.Pop()
        if ($frame.Depth -gt $MaxDepth) { continue }

        try {
            $entries = Get-ChildItem -LiteralPath $frame.Path -Force -ErrorAction Stop
        }
        catch {
            continue
        }

        foreach ($entry in $entries) {
            if ($entry.PSIsContainer) {
                if ($excludeDirs -contains $entry.Name) { continue }
                if ($frame.Depth -lt $MaxDepth) {
                    $stack.Push([PSCustomObject]@{ Path = $entry.FullName; Depth = $frame.Depth + 1 })
                }
                continue
            }

            if ($extSet.Contains($entry.Extension)) {
                $results += $entry
            }
        }
    }

    return $results
}

function New-FileEvidence {
    param(
        [System.IO.FileInfo] $File,
        [string] $RepoRoot
    )
    $rel = $File.FullName.Substring($RepoRoot.Length).TrimStart('\', '/').Replace('\', '/')
    return [ordered]@{
        path           = $rel
        last_write_utc = $File.LastWriteTimeUtc.ToString('o')
        length         = $File.Length
    }
}

function Get-RelativeNormalizedPath {
    param(
        [string] $FullPath,
        [string] $Root
    )
    $full = Get-NormalizedPath $FullPath
    $root = Get-NormalizedPath $Root
    if ($full.Equals($root, [StringComparison]::OrdinalIgnoreCase)) {
        return '.'
    }
    $prefix = $root + '/'
    if ($full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($prefix.Length)
    }
    return $full
}

function Test-CsprojReferencesEf {
    param([System.IO.FileInfo] $File)
    try {
        $text = Get-Content -LiteralPath $File.FullName -Raw -ErrorAction Stop
    }
    catch {
        return $false
    }
    return [bool]($text -match 'EntityFrameworkCore|Microsoft\.EntityFramework|EntityFramework\b')
}

function Get-PreservedBlockingLines {
    param([string] $GapsPath)
    if (-not (Test-Path -LiteralPath $GapsPath)) {
        return @()
    }
    $lines = Get-Content -LiteralPath $GapsPath
    $preserved = New-Object System.Collections.Generic.List[string]
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
    foreach ($line in $lines) {
        if ($line -notmatch 'BLOCKING:') {
            continue
        }
        $trimmed = $line.TrimEnd()
        if ($seen.Add($trimmed)) {
            [void]$preserved.Add($trimmed)
        }
    }
    return @($preserved)
}

function Merge-GapsMarkdown {
    param(
        [string] $GeneratedContent,
        [string[]] $PreservedBlocking
    )
    if (-not $PreservedBlocking -or $PreservedBlocking.Count -eq 0) {
        return $GeneratedContent
    }

    $blockingBody = ($PreservedBlocking -join "`n") + "`n"
    if ($GeneratedContent -match '(?ms)^## Blocking\r?\n') {
        return [regex]::Replace(
            $GeneratedContent,
            '(?ms)^## Blocking\r?\n.*?(?=^## |\z)',
            "## Blocking`n`n$blockingBody`n"
        )
    }

    return $GeneratedContent.TrimEnd() + "`n`n## Blocking`n`n$blockingBody"
}

$RepoPath = (Resolve-Path -LiteralPath $RepoPath).Path
if (-not $BankPath) {
    $BankPath = Join-Path $RepoPath 'memory-bank'
}
else {
    $BankPath = [IO.Path]::GetFullPath($BankPath)
}

$inventoryDir = Join-Path $BankPath '.inventory'
$sourcesPath = Join-Path $inventoryDir 'sources.json'
$gapsPath = Join-Path $inventoryDir 'gaps.md'
$historyPath = Join-Path $inventoryDir 'refresh-history.jsonl'

# Safety: bank under repo; inventory writes only under bank/.inventory
if (-not (Test-IsUnderRoot -Candidate $BankPath -Root $RepoPath)) {
    throw "BankPath must be under RepoPath. Bank=$BankPath Repo=$RepoPath"
}
if (-not (Test-IsUnderRoot -Candidate $inventoryDir -Root $BankPath)) {
    throw "Inventory path escapes bank root: $inventoryDir"
}

$lockfileNames = @(
    'package-lock.json', 'pnpm-lock.yaml', 'yarn.lock', 'bun.lockb',
    'Directory.Packages.props', 'packages.lock.json', 'Cargo.lock',
    'poetry.lock', 'uv.lock', 'go.sum', 'Gemfile.lock', 'composer.lock'
)
$manifestNames = @(
    'package.json', 'pyproject.toml', 'requirements.txt', 'Pipfile',
    'go.mod', 'Cargo.toml', 'Gemfile', 'composer.json', 'pom.xml',
    'build.gradle', 'build.gradle.kts', 'Directory.Build.props'
)
$docNames = @('README.md', 'README.MD', 'AGENTS.md', 'CLAUDE.md')

Write-Host "Scanning (read-only): $RepoPath" -ForegroundColor Cyan

$lockfiles = @(Find-FilesByName -Root $RepoPath -Names $lockfileNames -MaxDepth 6)
$manifests = @(Find-FilesByName -Root $RepoPath -Names $manifestNames -MaxDepth 6)
$docs = @(Find-FilesByName -Root $RepoPath -Names $docNames -MaxDepth 2)
$slnFiles = @(Find-FilesByExtension -Root $RepoPath -Extensions @('.sln') -MaxDepth 4)
$csprojFiles = @(Find-FilesByExtension -Root $RepoPath -Extensions @('.csproj') -MaxDepth 6)

$stackHints = New-Object System.Collections.Generic.List[string]
if ($manifests | Where-Object { $_.Name -eq 'package.json' }) { [void]$stackHints.Add('node') }
if ($csprojFiles.Count -gt 0 -or $slnFiles.Count -gt 0) { [void]$stackHints.Add('dotnet') }
if ($manifests | Where-Object { $_.Name -in @('pyproject.toml', 'requirements.txt', 'Pipfile') }) { [void]$stackHints.Add('python') }
if ($manifests | Where-Object { $_.Name -eq 'go.mod' }) { [void]$stackHints.Add('go') }
if ($manifests | Where-Object { $_.Name -eq 'Cargo.toml' }) { [void]$stackHints.Add('rust') }

$openapiHint = 'no'
$openapiHits = @(Find-FilesByName -Root $RepoPath -Names @('openapi.yaml', 'openapi.yml', 'openapi.json', 'swagger.json') -MaxDepth 6)
if ($openapiHits.Count -gt 0) { $openapiHint = 'yes' }

$dbHint = 'no'
$dbNameHits = @(Find-FilesByName -Root $RepoPath -Names @('prisma.schema', 'schema.prisma') -MaxDepth 6)
$efHits = @($csprojFiles | Where-Object { Test-CsprojReferencesEf -File $_ })
if ($dbNameHits.Count -gt 0 -or $efHits.Count -gt 0) {
    $dbHint = 'possible'
}
$migrationDirs = @('Migrations', 'migrations')
foreach ($dirName in $migrationDirs) {
    $hit = Get-ChildItem -LiteralPath $RepoPath -Directory -Filter $dirName -Recurse -Depth 6 -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($hit) { $dbHint = 'yes'; break }
}

$uiHint = 'no'
if ($manifests | Where-Object { $_.Name -eq 'package.json' }) {
    $uiHint = 'possible'
}

$generatedAt = (Get-Date).ToUniversalTime().ToString('o')
$sources = [ordered]@{
    schema_version = 1
    generated_at   = $generatedAt
    repo_path      = '.'
    bank_path      = (Get-RelativeNormalizedPath -FullPath $BankPath -Root $RepoPath)
    stale_days     = $StaleDays
    lockfiles      = @($lockfiles | ForEach-Object { New-FileEvidence -File $_ -RepoRoot $RepoPath })
    manifests      = @($manifests | ForEach-Object { New-FileEvidence -File $_ -RepoRoot $RepoPath })
    docs           = @($docs | ForEach-Object { New-FileEvidence -File $_ -RepoRoot $RepoPath })
    entry_points   = @(
        @($slnFiles | ForEach-Object { New-FileEvidence -File $_ -RepoRoot $RepoPath }) +
        @($csprojFiles | Select-Object -First 20 | ForEach-Object { New-FileEvidence -File $_ -RepoRoot $RepoPath })
    )
    stack_hints    = @($stackHints)
    notes          = @(
        "Read-only inventory. No application source modified.",
        "Paths in this file are relative to the consumer repo root.",
        "Recommend gitignoring memory-bank/.inventory/ in the consumer."
    )
}

$gapsContent = @"
# Inventory gaps

Unchecked items mean the bank is incomplete for that topic.
Use ``- [ ] BLOCKING:`` only when Step 0 must treat the bank as stale/incomplete.

## MVP coverage

- [ ] project-context filled from evidence
- [ ] tech-stack.json matches detected manifests
- [ ] architecture entry points verified
- [ ] domain-knowledge has at least one evidenced area (or N/A noted)
- [ ] conventions aligned with AGENTS/README
- [ ] known-risks reviewed once

## Phase 2 / optional rich contracts

- [ ] api-contracts (OpenAPI/Swagger detected: $openapiHint)
- [ ] database-schema (EF/Prisma/SQL migrations detected: $dbHint)
- [ ] component-catalog (design system / large UI kit detected: $uiHint)

## Blocking

## Notes

Regenerated by Invoke-MemoryBankInventory.ps1 at $generatedAt.
Stack hints: $($stackHints -join ', ')
"@

$preservedBlocking = @(Get-PreservedBlockingLines -GapsPath $gapsPath)
$gapsContent = Merge-GapsMarkdown -GeneratedContent $gapsContent -PreservedBlocking $preservedBlocking

$historyEntry = (@{
    at     = $generatedAt
    action = 'inventory'
    repo   = '.'
    hints  = @($stackHints)
} | ConvertTo-Json -Compress)

if ($DryRun) {
    Write-Host "[DryRun] Would write:" -ForegroundColor Yellow
    Write-Host "  $sourcesPath"
    Write-Host "  $gapsPath"
    if ($preservedBlocking.Count -gt 0) {
        Write-Host "  Preserving $($preservedBlocking.Count) BLOCKING line(s) in gaps.md"
    }
    Write-Host "  $historyPath (append)"
    Write-Host "Stack hints: $($stackHints -join ', ')"
    exit 0
}

if (-not (Test-Path -LiteralPath $inventoryDir)) {
    if (-not $AllowCreateInventory) {
        throw "Inventory dir missing: $inventoryDir. Re-run with -AllowCreateInventory or create via memory-bank-init."
    }
    New-Item -ItemType Directory -Path $inventoryDir -Force | Out-Null
}

# Final write-path guard
foreach ($target in @($sourcesPath, $gapsPath, $historyPath)) {
    if (-not (Test-IsUnderRoot -Candidate $target -Root $inventoryDir)) {
        throw "Refusing write outside .inventory/: $target"
    }
}

($sources | ConvertTo-Json -Depth 8) | Set-Content -Path $sourcesPath -Encoding UTF8
Set-Content -Path $gapsPath -Value $gapsContent -Encoding UTF8
Add-Content -Path $historyPath -Value $historyEntry -Encoding UTF8

Write-Host "Inventory written under: $inventoryDir" -ForegroundColor Green
Write-Host "  sources.json, gaps.md, refresh-history.jsonl" -ForegroundColor DarkGray
Write-Host "Stack hints: $($stackHints -join ', ')" -ForegroundColor DarkGray
