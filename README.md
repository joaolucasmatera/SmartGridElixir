# Smart Grid - Sistema Inteligente de Faturamento de Energia

Projeto educacional em **Elixir** demonstrando **programação funcional**, **pipelines imutáveis** e **pattern matching** para um sistema de faturamento de energia elétrica com detecção inteligente de outliers.

## 🎯 Visão Geral

O Smart Grid modela o faturamento como uma **pipeline de transformação imutável**:

```
Leituras Brutas → Validação → Cálculo Tarifário → Agregação → Fatura
    (Reading)    (Validator)    (Tarifa)        (Enum)     (Invoice)
```

### Características Principais

✅ **Pipelines Imutáveis**: Transformações de dados via operador `|>`  
✅ **Pattern Matching**: Regras tarifárias dinâmicas (bandeiras ANEEL)  
✅ **Análise Estatística**: Remoção automática de outliers (Z-score)  
✅ **Programação Funcional**: Funções puras, compostas, testáveis  
✅ **Type Safety**: Specs Elixir + Dialyzer ready  

## 📁 Estrutura do Projeto

```
smart_grid/
├── lib/smart_grid/
│   ├── reading.ex          # Struct: leitura do medidor (kwh, timestamp, perfil)
│   ├── invoice.ex          # Struct: fatura calculada (total, bandeira)
│   ├── validator.ex        # Validação + detecção de outliers (Z-score)
│   ├── tarifa.ex           # Regras tarifárias (bandeiras + perfis)
│   ├── pipeline.ex         # Orquestração completa (compose tudo)
│   └── smart_grid.ex       # Módulo principal
├── test/
│   ├── validator_test.exs  # Testes de validação
│   ├── tarifa_test.exs     # Testes de cálculo tarifário
│   └── pipeline_test.exs   # Testes de integração
├── config/
│   └── config.exs          # Configuração da aplicação
└── mix.exs                 # Dependências e configuração
```

## 🚀 Começando

### Pré-requisitos

- **Elixir 1.14+**
- **Erlang/OTP 25+**

Instalar via [elixir-lang.org](https://elixir-lang.org/install.html)

### Setup Inicial

```bash
# Instalar dependências
mix deps.get

# Compilar o projeto
mix compile

# Rodar os testes
mix test

# Modo interativo (IEx)
iex -S mix
```

## 📖 Exemplos de Uso

### 1️⃣ Processamento Simples

```elixir
iex> alias SmartGrid.{Reading, Pipeline}

# Criar leituras
iex> leituras = [
  %Reading{
    consumer_id: "C001",
    kwh: 100,
    profile: :residencial,
    timestamp: DateTime.utc_now()
  },
  %Reading{
    consumer_id: "C001",
    kwh: 105,
    profile: :residencial,
    timestamp: DateTime.utc_now()
  }
]

# Processar com bandeira amarela
iex> Pipeline.process(leituras, :amarela)
%SmartGrid.Invoice{
  total: 149.341,
  bandeira: :amarela,
  emitido_em: #DateTime<...>,
  consumo_kwh: 205.0,
  outliers_removidos: 0
}
```

### 2️⃣ Com Detecção de Outliers

```elixir
iex> leituras = [
  %Reading{consumer_id: "C001", kwh: 100, profile: :residencial, timestamp: DateTime.utc_now()},
  %Reading{consumer_id: "C001", kwh: 105, profile: :residencial, timestamp: DateTime.utc_now()},
  %Reading{consumer_id: "C001", kwh: 999, profile: :residencial, timestamp: DateTime.utc_now()}  # Outlier!
]

iex> invoice = Pipeline.process(leituras, :verde)
# O outlier (999 kWh) é automaticamente removido
# invoice.outliers_removidos == 1
# invoice.consumo_kwh == 205.0
```

### 3️⃣ Análise Estatística

```elixir
iex> Pipeline.analisar(leituras)
%{
  total_leituras: 3,
  validas: 2,
  outliers: 1,
  consumo_total_kwh: 205.0,
  consumo_medio_kwh: 102.5,
  desvio_padrao: 3.536,
  min_kwh: 100.0,
  max_kwh: 105.0
}
```

### 4️⃣ Processamento em Lote

```elixir
iex> consumidores = %{
  "C001" => [%Reading{...}, %Reading{...}],
  "C002" => [%Reading{...}],
  "C003" => [%Reading{...}, %Reading{...}, %Reading{...}]
}

iex> Pipeline.process_lote(consumidores, :amarela)
%{
  "C001" => %Invoice{...},
  "C002" => %Invoice{...},
  "C003" => %Invoice{...}
}
```

## 🧮 Regras Tarifárias

### Bandeiras ANEEL

| Bandeira | Multiplicador | Contexto |
|----------|---------------|----------|
| 🟢 Verde | 1.000 | Hidroelétricas cheias |
| 🟡 Amarela | 1.021 | Acionamento de térmicas |
| 🔴 Vermelha | 1.040 | Racionamento em risco |

### Perfis de Consumo

| Perfil | Tarifa Base | Uso |
|--------|------------|-----|
| Residencial | R$ 0.72/kWh | Casas |
| Comercial | R$ 0.85/kWh | Lojas, escritórios |
| Industrial | R$ 0.62/kWh | Fábricas (com desconto >500kWh) |

### Descontos

- **Volume**: Consumo > 500 kWh → -5% no valor final (perfil industrial)

### Pattern Matching em Ação

```elixir
# Em tarifa.ex - padrões declarativos

defp multiplicador(:verde),    do: 1.00
defp multiplicador(:amarela),  do: 1.021
defp multiplicador(:vermelha), do: 1.040

defp aplicar_desconto_volume(valor, kwh) when kwh > 500 do
  valor * 0.95  # 5% de desconto
end

defp aplicar_desconto_volume(valor, _kwh) do
  valor
end
```

## 🧪 Testes

### Rodar Testes

```bash
# Todos os testes
mix test

# Testes de um módulo específico
mix test test/smart_grid/validator_test.exs

# Testes com detalhes
mix test --verbose

# Com cobertura (requer ferramentas extras)
mix test --cover
```

### Estrutura de Testes

```elixir
# test/smart_grid/pipeline_test.exs
describe "process/2" do
  test "processa leituras simples e gera invoice" do
    leituras = [
      %Reading{kwh: 100, profile: :residencial, ...},
      %Reading{kwh: 105, profile: :residencial, ...}
    ]
    
    invoice = Pipeline.process(leituras, :verde)
    
    assert invoice.total == 147.6
    assert invoice.consumo_kwh == 205.0
  end
end
```

## 📚 Conceitos-Chave Demonstrados

### 1. Operator Pipe `|>`

```elixir
# Sem pipe (aninhamento)
criar_invoice(
  agregar(
    calcular_tarifas(
      validar(leituras)
    )
  ),
  bandeira
)

# Com pipe (composição limpa)
leituras
|> validar()
|> calcular_tarifas()
|> agregar()
|> criar_invoice(bandeira)
```

### 2. Pattern Matching

```elixir
# Desestruturação em parâmetros
def calcular(%Reading{kwh: kwh, profile: profile}, bandeira) do
  kwh * tarifa_base(profile) * multiplicador(bandeira)
end

# Guards para validação
def remover_outliers(leituras) when is_list(leituras) do
  ...
end
```

### 3. Funções de Ordem Superior

```elixir
# map, filter, reduce
leituras_validas
|> Enum.map(&Tarifa.calcular(&1, bandeira))      # map
|> Enum.filter(&(&1 > 0))                        # filter
|> Enum.reduce(0.0, &+/2)                        # reduce
```

### 4. Análise Estatística

```elixir
# Z-score para detectar outliers
def calcular_z_score(valor, media, desvio) do
  abs(valor - media) / desvio
end

# Z-score > 3 = outlier (99.7% dos dados)
```

## 🔄 Fluxo de Faturamento

```
┌─────────────────┐
│  Leituras Bruta │  (CSV, API, DB)
└────────┬────────┘
         │
         ▼
┌──────────────────────┐
│ 1️⃣ VALIDAÇÃO         │  Validator.remover_outliers/1
│ - kwh > 0           │  Remove inválidas e outliers
│ - Z-score ≤ 3       │  (99.7% dos dados normais)
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ 2️⃣ CÁLCULO TARIFÁRIO │  Tarifa.calcular/2
│ - Perfil             │  kWh × TarifaBase × Bandeira
│ - Bandeira           │  × DescontoVolume
│ - Desconto Volume    │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ 3️⃣ AGREGAÇÃO         │  Enum.sum/1
│ - Total              │  Soma todos os valores
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ 4️⃣ FATURA EMITIDA    │  Invoice.new/2
│ - Total              │  Struct com metadados
│ - Bandeira           │
│ - Timestamp          │
│ - Consumo            │
│ - Outliers removidos │
└──────────────────────┘
```

## 🛠 Desenvolvimento

### Adicionar Nova Feature

1. **Criar struct** (se necessário) em `lib/smart_grid/`
2. **Implementar lógica** com `@spec` e `@doc`
3. **Adicionar testes** em `test/smart_grid/`
4. **Integrar ao Pipeline** se apropriado

Exemplo: Adicionar suporte a eco-tarifa

```elixir
# lib/smart_grid/eco_tarifa.ex
defmodule SmartGrid.EcoTarifa do
  @moduledoc "Redução tarifária para consumo sustentável"
  
  @spec aplicar_desconto_eco(float(), Reading.t()) :: float()
  def aplicar_desconto_eco(valor, reading) do
    if leitura_sustentavel?(reading) do
      valor * 0.95  # 5% de desconto para padrão sustentável
    else
      valor
    end
  end
  
  defp leitura_sustentavel?(%Reading{kwh: kwh}) do
    kwh < 100  # Abaixo de 100 kWh
  end
end
```

## 📦 Dependências

```elixir
# mix.exs
{:decimal, "~> 2.1"}    # Precisão monetária (futuro)
{:ex_doc, "~> 0.30"}    # Documentação
{:credo, "~> 1.7"}      # Linting
```

## 🔗 Recursos

- [Elixir Docs](https://hexdocs.pm/elixir/)
- [Pipe Operator](https://elixir-lang.org/getting-started/pipe-operator.html)
- [Pattern Matching](https://elixir-lang.org/getting-started/pattern-matching.html)
- [ExUnit (Testes)](https://hexdocs.pm/ex_unit/)
- [ANEEL - Bandeiras Tarifárias](https://www.aneel.gov.br/)

## 📝 Licença

MIT

## 🎓 Autor

Desenvolvido como exemplo educacional de Programação Funcional em Elixir.

---

**Próximas melhorias**:
- [ ] Integração com banco de dados (Ecto)
- [ ] API REST (Phoenix)
- [ ] Dashboard de análises
- [ ] Relatórios em PDF
- [ ] Notificações por email
