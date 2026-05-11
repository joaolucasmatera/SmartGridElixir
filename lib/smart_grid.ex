defmodule SmartGridElixir do
  @moduledoc """
  SmartGridElixir - Sistema de faturamento inteligente de energia elétrica baseado em Elixir
  
  Implementa transformações imutáveis de leituras de medidores para faturas,
  utilizando pattern matching para regras tarifárias complexas e operador pipe
  para orquestração de pipeline de dados.
  
  ## Arquitetura
  
  - **Reading**: struct de entrada (leitura bruta do medidor)
  - **Validator**: filtra outliers e leituras inválidas
  - **Tarifa**: aplica regras tarifárias (bandeiras, perfis)
  - **Invoice**: struct de saída (fatura calculada)
  - **Pipeline**: orquestra todo o fluxo
  
  ## Exemplo
  
      iex> leituras = [
      ...>   %SmartGridElixir.Reading{kwh: 100, profile: :residencial, timestamp: ~U[2024-01-15 10:00:00Z]},
      ...>   %SmartGridElixir.Reading{kwh: 105, profile: :residencial, timestamp: ~U[2024-01-16 10:00:00Z]},
      ...>   %SmartGridElixir.Reading{kwh: 999, profile: :residencial, timestamp: ~U[2024-01-17 10:00:00Z]}
      ...> ]
      iex> SmartGridElixir.Pipeline.process(leituras, :amarela)
      %SmartGridElixir.Invoice{total: 21.441, bandeira: :amarela}
  """

  @doc """
  Versão da aplicação
  """
  def version, do: "0.1.0"
end
