# Configura este repositório no manifest.json do Spec Kit com o modo de armazenamento desejado.
param(
    [string]$StorageMode = "global"
)

# 1. Verificar pré-requisitos (specify-cli)
Write-Host "Verificando se specify-cli está disponível..." -ForegroundColor Cyan
try {
    $specVer = & specify --version 2>&1
    if ($specVer -match "specify \d") {
        Write-Host "specify-cli detectado: $specVer" -ForegroundColor Green
    }
    else {
        Write-Host "A CLI do Spec Kit não respondeu adequadamente." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "Erro: A CLI do Spec Kit não foi encontrada no PATH. Execute primeiro o setup-speckit.ps1 e garanta que o terminal foi reiniciado." -ForegroundColor Red
    exit 1
}

$sddPath = Join-Path $env:USERPROFILE ".cursor\sdd"
$manifestPath = Join-Path $sddPath "manifest.json"

if (-not (Test-Path $manifestPath)) {
    Write-Host "Erro: O arquivo manifest.json não existe. Execute primeiro o setup-speckit.ps1." -ForegroundColor Red
    exit 1
}

# Carregar manifest
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
if (-not $manifest.repositories) {
    $manifest.repositories = [PSCustomObject]@{}
}

$cwd = (Get-Item .).FullName.Replace('\', '/')
$repoName = Split-Path $cwd -Leaf
$targetPath = ""

if ($StorageMode -eq "global") {
    $targetPath = Join-Path $sddPath $repoName
}
else {
    $targetPath = $cwd
}

# Normalizar caminhos com barras normais para compatibilidade
$targetPath = $targetPath.Replace('\', '/')

# Atualizar o manifest
$manifest.repositories | Add-Member -MemberType NoteProperty -Name $cwd -Value @{
    storage_mode = $StorageMode
    path         = $targetPath
} -Force

$json = $manifest | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($manifestPath, $json)
Write-Host "Repositório configurado no manifest.json!" -ForegroundColor Green

# 2. Verificar se .specify/ já existe no destino
$specifyFolderPath = Join-Path $targetPath ".specify"
if (Test-Path $specifyFolderPath) {
    Write-Host "A estrutura .specify/ já existe em '$targetPath'. Não vou sobrescrever uma configuração existente. Encerrando." -ForegroundColor Yellow
    exit 0
}

# Criar pasta pai se for modo global e não existir
# Não criamos o diretório final (targetPath) pois o specify init prefere criá-lo ou reclama se já existir sem --force.
$parentDir = Split-Path $targetPath
if ($StorageMode -eq "global" -and -not (Test-Path $parentDir)) {
    New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
}

# 3. Inicializar via CLI
Write-Host "Inicializando Spec Kit no destino: $targetPath" -ForegroundColor Cyan
if ($StorageMode -eq "global") {
    & specify init $targetPath --integration generic --integration-options="--commands-dir .specify/commands/" --force
}
else {
    & specify init . --integration generic --integration-options="--commands-dir .specify/commands/" --force
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro: Falha ao executar 'specify init'." -ForegroundColor Red
    exit 1
}

# 4. Validar resultado
$constitutionPath = Join-Path $specifyFolderPath "memory/constitution.md"
if (Test-Path $constitutionPath) {
    Write-Host "`n✅ Spec Kit inicializado em '$targetPath'. A constitution está em '$targetPath/.specify/memory/constitution.md'." -ForegroundColor Green
}
else {
    Write-Host "`n⚠️ A inicialização completou mas 'constitution.md' não foi encontrado em '$targetPath/.specify/memory/'. Verifique o diretório manualmente." -ForegroundColor Yellow
}
