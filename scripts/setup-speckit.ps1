# Script para configurar o Spec Kit no Windows (cursor-dev-toolkit)
# Executa as validações e instalações necessárias conforme a especificação do speckit_setup.

Write-Host "Iniciando a configuração do GitHub Spec Kit..." -ForegroundColor Cyan

# 1. Verificar Python
$pythonInstalled = $false
try {
    $pyVersion = & python --version 2>&1
    if ($pyVersion -match "Python 3\.(1[0-9]|[2-9])") {
        Write-Host "Python detectado: $pyVersion" -ForegroundColor Green
        $pythonInstalled = $true
    } else {
        Write-Host "Python encontrado, mas a versão é inferior a 3.10: $pyVersion" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Python não encontrado no PATH." -ForegroundColor Yellow
}

if (-not $pythonInstalled) {
    $response = Read-Host "O Python 3.10+ não foi encontrado no PATH. Deseja tentar instalá-lo via winget? (sim / não)"
    if ($response -eq "sim") {
        Write-Host "Instalando Python 3.12 via winget..."
        winget install -e --id Python.Python.3.12
        Write-Host "Por favor, reinicie seu terminal após a instalação e execute este script novamente." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "Instalação do Python cancelada. Por favor, resolva manualmente:" -ForegroundColor Red
        Write-Host "1. Abra o terminal como Administrador e rode: winget install -e --id Python.Python.3.12"
        Write-Host "2. Ou baixe o instalador oficial: https://www.python.org/downloads/"
        exit
    }
}

# 2. Verificar uv
$uvInstalled = $false
try {
    $uvVer = & uv --version 2>&1
    if ($uvVer -match "uv \d") {
        Write-Host "uv detectado: $uvVer" -ForegroundColor Green
        $uvInstalled = $true
    }
} catch {
    Write-Host "Gerenciador 'uv' não encontrado." -ForegroundColor Yellow
}

if (-not $uvInstalled) {
    $response = Read-Host "O gerenciador 'uv' não foi encontrado. Deseja que eu execute a instalação? (sim / não)"
    if ($response -eq "sim") {
        Write-Host "Instalando 'uv'..."
        powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"
        # Refresh PATH para a sessão atual
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        Write-Host "Por favor, instale o 'uv' manualmente executando este comando no terminal:" -ForegroundColor Red
        Write-Host 'powershell -ExecutionPolicy Bypass -c "irm https://astral.sh/uv/install.ps1 | iex"' -ForegroundColor Yellow
        exit
    }
}

# 3. Instalar specify-cli
Write-Host "Verificando 'specify-cli'..."
$specifyInstalled = $false
try {
    $specVer = & specify --version 2>&1
    if ($specVer -match "specify \d") {
        Write-Host "specify-cli detectado: $specVer" -ForegroundColor Green
        $specifyInstalled = $true
    }
} catch {
    Write-Host "specify-cli não detectado." -ForegroundColor Yellow
}

if (-not $specifyInstalled) {
    Write-Host "Instalando specify-cli via uv..."
    & uv tool install specify-cli --from git+https://github.com/github/spec-kit.git --force
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Falha ao instalar specify-cli via uv. Tente executar manualmente no terminal:" -ForegroundColor Red
        Write-Host "uv tool install specify-cli --from git+https://github.com/github/spec-kit.git --force" -ForegroundColor Yellow
    } else {
        Write-Host "specify-cli instalado com sucesso!" -ForegroundColor Green
    }
}

# 4. Inicializar diretórios globais
$sddPath = Join-Path $env:USERPROFILE ".cursor\sdd"
if (-not (Test-Path $sddPath)) {
    Write-Host "Criando diretório global: $sddPath"
    New-Item -ItemType Directory -Force -Path $sddPath | Out-Null
}

$manifestPath = Join-Path $sddPath "manifest.json"
if (-not (Test-Path $manifestPath)) {
    Write-Host "Inicializando manifest.json..."
    '{"repositories": {}}' | Out-File -FilePath $manifestPath -Encoding utf8
}

Write-Host "`n✅ Setup do Spec Kit concluído. Todos os pré-requisitos estão instalados e o diretório global de SDD foi inicializado." -ForegroundColor Green
