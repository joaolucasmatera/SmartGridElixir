defmodule SmartGrid.Validator do
  @moduledoc """
  Valida leituras e remove outliers usando análise estatística.
  
  Implementa detecção de outliers via desvio padrão (Z-score).
  Qualquer leitura com Z-score > 3 é considerada outlier.
  """

  require Logger

  @doc """
  Remove leituras inválidas (kwh <= 0) e outliers estatísticos.
  
  Retorna uma tupla {leituras_válidas, quantidade_removidas}
  """
  @spec remover_outliers([SmartGrid.Reading.t()]) :: {[SmartGrid.Reading.t()], non_neg_integer()}
  def remover_outliers([]), do: {[], 0}
  
  def remover_outliers(leituras) when is_list(leituras) do
    # Filtro 1: Remove inválidas (kwh <= 0)
    validas = Enum.filter(leituras, & &1.kwh > 0)
    removidas_invalidas = length(leituras) - length(validas)

    case validas do
      [] ->
        {[], removidas_invalidas}

      [unica] ->
        {[unica], removidas_invalidas}

      multiplas ->
        # Filtro 2: Remove outliers estatísticos
        media = calcular_media(multiplas)
        desvio = calcular_desvio_padrao(multiplas, media)

        {sem_outliers, removidas_outliers} =
          multiplas
          |> Enum.map(&{&1, calcular_z_score(&1.kwh, media, desvio)})
          |> Enum.partition(fn {_reading, z_score} -> z_score <= 3 end)
          |> (fn {validas, invalidas} -> {Enum.map(validas, &elem(&1, 0)), length(invalidas)} end).()

        Logger.debug(
          "Validator: #{removidas_invalidas} inválidas, #{removidas_outliers} outliers removidos"
        )

        {sem_outliers, removidas_invalidas + removidas_outliers}
    end
  end

  @doc """
  Calcula a média aritmética de kWh em uma lista de leituras.
  """
  @spec calcular_media([SmartGrid.Reading.t()]) :: float()
  def calcular_media(leituras) do
    total = Enum.reduce(leituras, 0.0, &(&1.kwh + &2))
    total / length(leituras)
  end

  @doc """
  Calcula o desvio padrão de kWh em uma lista de leituras.
  """
  @spec calcular_desvio_padrao([SmartGrid.Reading.t()], float()) :: float()
  def calcular_desvio_padrao(leituras, media \\ nil) do
    media = media || calcular_media(leituras)

    sum_sq_diff =
      leituras
      |> Enum.map(&((&1.kwh - media) ** 2))
      |> Enum.sum()

    variancia = sum_sq_diff / length(leituras)
    :math.sqrt(variancia)
  end

  @doc """
  Calcula o Z-score de um valor dado a média e desvio padrão.
  Z-score indica quantos desvios padrão um valor está da média.
  """
  @spec calcular_z_score(float(), float(), float()) :: float()
  def calcular_z_score(valor, media, desvio) when desvio == 0 do
    if valor == media, do: 0.0, else: :infinity
  end

  def calcular_z_score(valor, media, desvio) do
    abs(valor - media) / desvio
  end

  @doc """
  Valida se uma leitura individual é válida (kwh > 0).
  """
  @spec valida?(SmartGrid.Reading.t()) :: boolean()
  def valida?(reading) do
    reading.kwh > 0 && reading.valid
  end
end
