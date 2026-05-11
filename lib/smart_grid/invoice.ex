defmodule SmartGridElixir.Invoice do
  @moduledoc """
  Struct imutável representando uma fatura de energia calculada.

  Campos:
  - `total`: Valor total em reais (Decimal para precisão)
  - `bandeira`: Bandeira tarifária (verde, amarela, vermelha)
  - `emitido_em`: Timestamp de quando a fatura foi gerada
  - `consumo_kwh`: Total de kWh consumidos no período
  - `outliers_removidos`: Quantidade de leituras descartadas por outliers
  """

  defstruct [
    :total,
    :bandeira,
    :emitido_em,
    consumo_kwh: 0.0,
    outliers_removidos: 0
  ]

  @type bandeira :: :verde | :amarela | :vermelha

  @type t :: %__MODULE__{
    total: Decimal.t() | float(),
    bandeira: bandeira(),
    emitido_em: DateTime.t(),
    consumo_kwh: float(),
    outliers_removidos: non_neg_integer()
  }

  @doc """
  Cria uma nova fatura a partir do total calculado.
  """
  @spec new(float() | Decimal.t(), bandeira(), keyword()) :: t()
  def new(total, bandeira, opts \\ []) do
    %__MODULE__{
      total: total,
      bandeira: bandeira,
      emitido_em: DateTime.utc_now(),
      consumo_kwh: Keyword.get(opts, :consumo_kwh, 0.0),
      outliers_removidos: Keyword.get(opts, :outliers_removidos, 0)
    }
  end

  @doc """
  Formata a fatura para exibição.
  """
  @spec format(t()) :: String.t()
  def format(invoice) do
    total_str = Float.round(invoice.total, 2) |> to_string()

    """
    === FATURA DE ENERGIA ===
    Bandeira: #{String.upcase(to_string(invoice.bandeira))}
    Consumo: #{invoice.consumo_kwh} kWh
    Outliers removidos: #{invoice.outliers_removidos}
    Total: R$ #{total_str}
    Emitida em: #{DateTime.to_iso8601(invoice.emitido_em)}
    """
  end
end
