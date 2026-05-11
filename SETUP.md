# Guia de Instalação - Smart Grid

## ⚙️ Pré-requisitos

### Windows

#### 1. Instalar Elixir e Erlang

**Opção A: Via Chocolatey (Recomendado)**

```powershell
# Abrir PowerShell como Administrador
choco install elixir erlang
```

**Opção B: Via Scoop**

```powershell
scoop install erlang elixir
```

**Opção C: Download Manual**

1. Baixar OTP (Erlang) em: https://www.erlang.org/downloads
2. Instalar Erlang
3. Baixar Elixir em: https://elixir-lang.org/install.html
4. Descompactar e adicionar ao PATH

#### 2. Verificar Instalação

```powershell
elixir --version
erlang --version
mix --version
```

Você deve ver versões similares a:
```
Elixir 1.14.x
Erlang/OTP 25.x
Mix 1.14.x
```

### macOS

```bash
brew install elixir erlang
```

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install elixir erlang
```

## 🚀 Setup do Projeto

```bash
# Navegar ao diretório do projeto
cd c:\Users\lucas\Documents\CarrinhoArduino

# Instalar dependências
mix deps.get

# Compilar o projeto
mix compile

# Rodar testes
mix test

# Modo interativo
iex -S mix
```

## ✅ Validação

Se os comandos acima funcionarem sem erros, o projeto está pronto!

```powershell
mix test --verbose
```

Você deve ver:
```
...
Finished in X.XXXs
Y tests, 0 failures
```

## 🔧 Troubleshooting

### `mix: command not found`

**Solução**: Elixir não está no PATH
- Reinstalar Elixir
- Adicionar manualmente ao PATH:
  - Windows: `C:\Program Files\Elixir\bin`
  - macOS/Linux: `/usr/local/bin`

### Erro ao rodar `mix deps.get`

```bash
mix local.hex --if-missing
mix local.rebar --if-missing
mix deps.get
```

### Porta já em uso (ao rodar testes)

Testes unitários não usam porta, mas se precisar:

```bash
lsof -i :4000  # macOS/Linux
netstat -ano | findstr :4000  # Windows
```

## 📚 Próximos Passos

1. Ler o [README.md](./README.md) para entender a arquitetura
2. Abrir `iex -S mix` e testar os exemplos
3. Explorar os arquivos em `lib/smart_grid/`
4. Rodar `mix test` e examinar os testes

## 🆘 Suporte

- [Elixir Getting Started](https://elixir-lang.org/getting-started/introduction.html)
- [Elixir Forum](https://elixirforum.com/)
- [Hex Documentation](https://hex.pm/)
