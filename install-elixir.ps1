# Script para instalar Elixir no Windows
# Requer PowerShell como Administrador

Write-Host "=== Instalador de Elixir para Windows ===" -ForegroundColor Green
Write-Host ""

# Verificar se está rodando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "ERRO: Execute este script como Administrador!" -ForegroundColor Red
    Write-Host "Clique com botão direito em PowerShell > Executar como administrador" -ForegroundColor Yellow
    exit 1
}

# Instalar Chocolatey se não existir
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Chocolatey..." -ForegroundColor Cyan
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Instalar Erlang
Write-Host "Instalando Erlang/OTP..." -ForegroundColor Cyan
choco install erlang -y --no-progress

# Instalar Elixir
Write-Host "Instalando Elixir..." -ForegroundColor Cyan
choco install elixir -y --no-progress

# Atualizar PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verificar instalação
Write-Host ""
Write-Host "Verificando instalação..." -ForegroundColor Cyan
Write-Host ""

$erlang = erlang -eval 'erlang:halt()' 2>&1 | Select-String "Eshell"
$elixir_v = elixir --version 2>&1
$mix_v = mix --version 2>&1

Write-Host "✓ Erlang: $erlang" -ForegroundColor Green
Write-Host "✓ Elixir: $elixir_v" -ForegroundColor Green
Write-Host "✓ Mix: $mix_v" -ForegroundColor Green

Write-Host ""
Write-Host "=== Instalacao Concluida ===" -ForegroundColor Green
Write-Host "Feche e reabra o PowerShell para atualizar as variaveis de ambiente" -ForegroundColor Yellow
