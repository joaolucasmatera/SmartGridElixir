defmodule SmartGrid.Tarifa do
  @moduledoc """
  Implementa as regras tarifárias complexas usando pattern matching.
  
  Bandeiras:
  - Verde: multiplicador 1.00
  - Amarela: multiplicador 1.021
  - Vermelha: multiplicador 1.040
  
  Perfis:
  - Residencial: R$ 0.72 / kWh (base)
  - Comercial: R$ 0.85 / kWh (base)
  - Industrial: R$ 0.62 / kWh (base) - desconto por volume
  """

  require Logger

  @bandeira_multiplicadores %{
    verde: 1.00,
    amarela: 1.021,
    vermelha: 1.040
  }

  @tarifa_base %{
    residencial: 0.72,
    comercial: 0.85,
    industrial: 0.62
  }

  @doc """
  Calcula o valor de uma leitura baseado em bandeira e perfil.
  
  Retorna um float com o valor em reais.
  """
  @spec calcular(SmartGrid.Reading.t(), SmartGrid.Invoice.bandeira()) :: float()
  def calcular(%SmartGrid.Reading{} = reading, bandeira) when bandeira in [:verde, :amarela, :vermelha] do
    reading.kwh
    |> multiplicar_por_tarifa_base(reading.profile)
    |> aplicar_bandeira(bandeira)
    |> aplicar_desconto_volume(reading.kwh)
  end

  @doc """
  Retorna o multiplicador para uma bandeira.
  """
  @spec multiplicador(SmartGrid.Invoice.bandeira()) :: float()
  def multiplicador(bandeira) do
    Map.get(@bandeira_multiplicadores, bandeira, 1.0)
  end

  @doc """
  Retorna a tarifa base para um perfil.
  """
  @spec tarifa_base(SmartGrid.Reading.profile()) :: float()
  def tarifa_base(profile) do
    Map.get(@tarifa_base, profile, 0.72)
  end

  @doc """
  Retorna informações sobre as bandeiras atuais.
  """
  @spec info_bandeiras() :: map()
  def info_bandeiras do
    Map.new(@bandeira_multiplicadores, fn {bandeira, mult} ->
      {bandeira, %{multiplicador: mult, tarifa_base: @tarifa_base}}
    end)
  end

  # Funções privadas

  defp multiplicar_por_tarifa_base(kwh, profile) do
    kwh * tarifa_base(profile)
  end

  defp aplicar_bandeira(valor, bandeira) do
    valor * multiplicador(bandeira)
  end

  defp aplicar_desconto_volume(valor, kwh) when kwh > 500 do
    # Desconto de 5% para consumo acima de 500 kWh
    valor * 0.95
  end

  defp aplicar_desconto_volume(valor, _kwh) do
    valor
  end
end
