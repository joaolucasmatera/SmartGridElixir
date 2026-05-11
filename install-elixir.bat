@echo off
REM Script para instalar Elixir e dependências no Windows
REM Deve ser executado como Administrador

title Instalador Elixir - SmartGridElixir

echo.
echo ========================================
echo  Instalador Elixir para SmartGridElixir
echo ========================================
echo.

REM Verificar se está como admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERRO: Execute este script como Administrador!
    echo Clique com botao direito e escolha "Executar como administrador"
    pause
    exit /b 1
)

echo [1/3] Instalando Scoop...
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb get.scoop.sh | iex"

if %errorLevel% neq 0 (
    echo ERRO ao instalar Scoop
    pause
    exit /b 1
)

echo.
echo [2/3] Atualizando PATH...
call refreshenv
set "PATH=%USERPROFILE%\scoop\shims;%PATH%"

echo.
echo [3/3] Instalando Erlang e Elixir...
scoop install erlang elixir

if %errorLevel% neq 0 (
    echo ERRO ao instalar Erlang/Elixir
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Verificando instalacao...
echo ========================================
echo.

where elixir >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Elixir instalado
    elixir --version
) else (
    echo [ERRO] Elixir nao encontrado
)

where erl >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Erlang instalado
) else (
    echo [ERRO] Erlang nao encontrado
)

echo.
echo ========================================
echo  Instalacao concluida!
echo ========================================
echo.
echo Feche e reabra o PowerShell para completar a configuracao.
echo Depois execute: cd c:\Users\lucas\Documents\CarrinhoArduino
echo              : mix deps.get
echo              : mix test

pause
