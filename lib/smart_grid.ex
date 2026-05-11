defmodule SmartGrid do
  @moduledoc """
  Smart Grid - Sistema de faturamento inteligente de energia elétrica
  
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
      ...>   %SmartGrid.Reading{kwh: 100, profile: :residencial, timestamp: ~U[2024-01-15 10:00:00Z]},
      ...>   %SmartGrid.Reading{kwh: 105, profile: :residencial, timestamp: ~U[2024-01-16 10:00:00Z]},
      ...>   %SmartGrid.Reading{kwh: 999, profile: :residencial, timestamp: ~U[2024-01-17 10:00:00Z]}
      ...> ]
      iex> SmartGrid.Pipeline.process(leituras, :amarela)
      %SmartGrid.Invoice{total: 21.441, bandeira: :amarela}
  """

  @doc """
  Versão da aplicação
  """
  def version, do: "0.1.0"
end
