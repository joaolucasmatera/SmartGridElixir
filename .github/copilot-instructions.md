<!-- Smart Grid - Project-specific Copilot Instructions -->

# Smart Grid - Instruções para Copilot

## Contexto do Projeto

Smart Grid é um sistema de faturamento inteligente de energia elétrica baseado em **Elixir**, implementando:

- **Transformações imutáveis**: Pipeline de dados usando o operador `|>`
- **Pattern matching**: Regras tarifárias complexas (bandeiras verde/amarela/vermelha)
- **Análise estatística**: Remoção de outliers via Z-score
- **Programação funcional**: Funções de alta ordem e reduções

## Princípios Arquiteturais

1. **Separação de responsabilidades**:
   - `Reading`: Struct de entrada (imutável)
   - `Validator`: Validação e detecção de outliers
   - `Tarifa`: Regras tarifárias via pattern matching
   - `Pipeline`: Orquestração via `|>` operator
   - `Invoice`: Struct de saída

2. **Imutabilidade**: Não modificamos dados, sempre retornamos novos valores

3. **Composição**: Funções pequenas, puras, compostas via pipe

4. **Testabilidade**: Lógica pura sem I/O, fácil testar

## Estrutura de Diretórios

```
lib/smart_grid/
  ├── reading.ex          # Struct: leitura do medidor
  ├── invoice.ex          # Struct: fatura gerada
  ├── validator.ex        # Validação e outliers
  ├── tarifa.ex           # Regras tarifárias (pattern matching)
  └── pipeline.ex         # Orquestração (pipe operator)

test/smart_grid/
  ├── validator_test.exs  # Testes de validação
  ├── tarifa_test.exs     # Testes de tarifação
  └── pipeline_test.exs   # Testes de integração
```

## Convenções de Código

- Usar `defmodule` para cada conceito
- Usar `@spec` para type hints
- Usar `@moduledoc` e `@doc` para documentação
- Usar `require Logger` para logging
- Pattern matching em heads de função para validação
- Funções privadas com `defp`

## Fluxo de Desenvolvimento

1. **Feature**: Descrever o que vai fazer
2. **Spec**: Definir tipo e contrato
3. **Implementação**: Code imutável, composável
4. **Testes**: ExUnit com fixtures simples
5. **Integração**: Via Pipeline.process/2

## Recursos Úteis

- Operador pipe: `|>` para composição
- Pattern matching: `%Reading{kwh: kwh}` para destructuring
- Enum: `.map()`, `.filter()`, `.reduce()` para transformações
- Decimal: Para precisão monetária (futuro)
- ExUnit: Framework de testes padrão Elixir
