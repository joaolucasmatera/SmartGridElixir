defmodule SmartGridElixir.APIDemo do
  @moduledoc """
  Demo script para testar a API REST de faturamento.

  Execute no IEx:
  ```
  iex> SmartGridElixir.APIDemo.test_api()
  ```
  """

  alias SmartGridElixir.{Reading, Pipeline}

  def test_api do
    IO.puts("\n=== SmartGrid API Demo ===\n")

    # 1. Criar leituras de teste
    readings = [
      %Reading{consumer_id: "C001", kwh: 100.0, timestamp: "2024-01-01", profile: :residencial, valid: true},
      %Reading{consumer_id: "C001", kwh: 110.0, timestamp: "2024-01-02", profile: :residencial, valid: true},
      %Reading{consumer_id: "C001", kwh: 105.0, timestamp: "2024-01-03", profile: :residencial, valid: true},
      %Reading{consumer_id: "C001", kwh: 500.0, timestamp: "2024-01-04", profile: :residencial, valid: true} # Outlier potencial
    ]

    IO.puts("📊 Leituras geradas: #{length(readings)}")
    Enum.each(readings, &IO.puts("   - #{&1.kwh} kWh"))

    # 2. Processar com bandeira verde
    IO.puts("\n🟢 Processando com bandeira VERDE...\n")
    result = Pipeline.process_with_details(readings, :verde)

    invoice = result[:invoice]
    IO.puts("✓ Fatura gerada:")
    IO.puts("  Total: R$ #{Float.round(invoice.total, 2)}")
    IO.puts("  Consumo: #{Float.round(result[:consumo_kwh], 2)} kWh")
    IO.puts("  Outliers removidos: #{result[:outliers_removidos]}")
    IO.puts("  Tempo processamento: #{result[:tempo_processamento_ms]}ms")

    # 3. Processar com bandeira vermelha
    IO.puts("\n🔴 Processando com bandeira VERMELHA...\n")
    result_red = Pipeline.process_with_details(readings, :vermelha)
    invoice_red = result_red[:invoice]

    IO.puts("✓ Fatura gerada:")
    IO.puts("  Total: R$ #{Float.round(invoice_red.total, 2)}")
    IO.puts("  Diferença: +#{Float.round(invoice_red.total - invoice.total, 2)} (#{Float.round((invoice_red.total / invoice.total - 1) * 100, 1)}%)")

    # 4. Formato JSON para microsserviço
    IO.puts("\n📡 Resposta JSON para microsserviço:\n")
    json_response = %{
      "consumerId" => "C001",
      "totalAmount" => Float.round(invoice.total, 2),
      "consumptionKwh" => Float.round(result[:consumo_kwh], 2),
      "profile" => "residencial",
      "bandeira" => "verde",
      "outliers" => result[:outliers_removidos],
      "generatedAt" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

    IO.puts(Jason.encode!(json_response, pretty: true))

    :ok
  end
end
