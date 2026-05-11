defmodule SmartGridElixir.Pipeline do
  @moduledoc """
  Orquestra o fluxo completo de transformação de leituras em faturas.
  
  Implementa a pipeline imutável:
  1. Valida leituras (remove inválidas e outliers)
  2. Calcula valor de cada leitura aplicando tarifa e bandeira
  3. Agrega o total
  4. Gera invoice com metadados
  """

  require Logger
  alias SmartGridElixir.{Reading, Invoice, Validator, Tarifa}

  @doc """
  Processa uma lista de leituras e retorna uma fatura.
  
  Usa o operador pipe |> para orquestrar as transformações:
  - Entrada: lista de Reading
  - Saída: Invoice
  """
  @spec process([Reading.t()], Invoice.bandeira()) :: Invoice.t()
  def process(leituras, bandeira) when is_list(leituras) and bandeira in [:verde, :amarela, :vermelha] do
    Logger.info("Pipeline iniciado com #{length(leituras)} leituras (bandeira: #{bandeira})")

    {leituras_validas, outliers} = Validator.remover_outliers(leituras)

    leituras_validas
    |> Enum.map(&Tarifa.calcular(&1, bandeira))
    |> Enum.sum()
    |> criar_invoice(bandeira, leituras_validas, outliers)
  end

  @doc """
  Processa leituras e retorna um mapa com detalhes da execução.
  """
  @spec process_with_details([Reading.t()], Invoice.bandeira()) :: map()
  def process_with_details(leituras, bandeira) when is_list(leituras) do
    Logger.info("Pipeline (detalhado) iniciado com #{length(leituras)} leituras")

    start_time = System.monotonic_time(:millisecond)
    
    {leituras_validas, outliers} = Validator.remover_outliers(leituras)
    consumo_total = Enum.reduce(leituras_validas, 0.0, &(&1.kwh + &2))

    valores =
      leituras_validas
      |> Enum.map(fn reading ->
        valor = Tarifa.calcular(reading, bandeira)
        {reading, valor}
      end)

    total = Enum.reduce(valores, 0.0, fn {_reading, valor}, acc -> valor + acc end)
    
    end_time = System.monotonic_time(:millisecond)
    tempo_ms = end_time - start_time

    invoice = criar_invoice(total, bandeira, leituras_validas, outliers)

    %{
      invoice: invoice,
      total_leituras: length(leituras),
      leituras_validas: length(leituras_validas),
      outliers_removidos: outliers,
      consumo_kwh: consumo_total,
      valores_por_leitura: valores,
      tempo_processamento_ms: tempo_ms,
      bandeira: bandeira
    }
  end

  @doc """
  Processa múltiplas leituras agrupadas por consumidor e bandeira.
  Retorna um mapa de consumidor_id -> Invoice.
  """
  @spec process_lote(map(), Invoice.bandeira()) :: map()
  def process_lote(leituras_por_consumidor, bandeira) when is_map(leituras_por_consumidor) do
    Logger.info("Pipeline (lote) iniciado para #{map_size(leituras_por_consumidor)} consumidores")

    Map.new(leituras_por_consumidor, fn {consumer_id, leituras} ->
      invoice = process(leituras, bandeira)
      {consumer_id, invoice}
    end)
  end

  @doc """
  Analisa leituras e retorna estatísticas gerais (sem gerar fatura).
  """
  @spec analisar([Reading.t()]) :: map()
  def analisar(leituras) when is_list(leituras) do
    {leituras_validas, outliers} = Validator.remover_outliers(leituras)

    consumo_total = Enum.reduce(leituras_validas, 0.0, &(&1.kwh + &2))
    media = Validator.calcular_media(leituras_validas)
    desvio = Validator.calcular_desvio_padrao(leituras_validas, media)

    %{
      total_leituras: length(leituras),
      validas: length(leituras_validas),
      outliers: outliers,
      consumo_total_kwh: consumo_total,
      consumo_medio_kwh: media,
      desvio_padrao: desvio,
      min_kwh: Enum.min_by(leituras_validas, &(&1.kwh), fn -> nil end) |> then(&(&1.kwh)),
      max_kwh: Enum.max_by(leituras_validas, &(&1.kwh), fn -> nil end) |> then(&(&1.kwh))
    }
  rescue
    _ -> %{error: "Não há leituras válidas para análise"}
  end

  # Funções privadas

  defp criar_invoice(total, bandeira, leituras_validas, outliers) do
    consumo = Enum.reduce(leituras_validas, 0.0, &(&1.kwh + &2))

    Invoice.new(total, bandeira,
      consumo_kwh: consumo,
      outliers_removidos: outliers
    )
  end
end
