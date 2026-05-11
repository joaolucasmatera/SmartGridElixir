defmodule SmartGrid.Reading do
  @moduledoc """
  Struct imutável representando uma leitura de medidor de energia.
  
  Campos:
  - `consumer_id`: ID do consumidor (UUID ou string)
  - `kwh`: Quantidade de kWh consumidos (float)
  - `timestamp`: Data/hora da leitura
  - `profile`: Perfil de consumo (:residencial, :comercial, :industrial)
  - `valid`: Flag indicando se a leitura passou validação (padrão: true)
  """

  defstruct [
    :consumer_id,
    :kwh,
    :timestamp,
    profile: :residencial,
    valid: true
  ]

  @type profile :: :residencial | :comercial | :industrial
  
  @type t :: %__MODULE__{
    consumer_id: String.t(),
    kwh: float(),
    timestamp: DateTime.t(),
    profile: profile(),
    valid: boolean()
  }

  @doc """
  Cria uma nova leitura com validações básicas.
  """
  @spec new(String.t(), float(), DateTime.t(), profile()) :: t()
  def new(consumer_id, kwh, timestamp, profile \\ :residencial) do
    %__MODULE__{
      consumer_id: consumer_id,
      kwh: kwh,
      timestamp: timestamp,
      profile: profile,
      valid: kwh > 0
    }
  end
end
