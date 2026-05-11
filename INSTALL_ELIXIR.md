# ⚡ Instalação Rápida do Elixir

## Opção 1: Script Automatizado (Recomendado)

```powershell
# Abrir PowerShell como ADMINISTRADOR
# Depois execute:

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
.\install-elixir.ps1
```

## Opção 2: Manual via Chocolatey

```powershell
# Abrir PowerShell como ADMINISTRADOR
# Depois execute:

# Instalar Chocolatey (se não tiver)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar Erlang e Elixir
choco install erlang elixir -y
```

## Opção 3: Download Manual

1. **Erlang/OTP**: https://www.erlang.org/downloads
2. **Elixir**: https://elixir-lang.org/install.html#windows

(Descompactar e adicionar ao PATH)

## Verificar Instalação

Após instalar, **feche e reabra o PowerShell**, depois:

```powershell
elixir --version
mix --version
```

Você deve ver versões similares a:
```
Elixir 1.14.x
Mix 1.14.x
```

## Próximo Passo

Quando Elixir estiver instalado, volte aqui e execute:

```powershell
cd "c:\Users\lucas\Documents\CarrinhoArduino"
mix deps.get
mix test
```
