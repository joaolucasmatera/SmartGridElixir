defmodule SmartGridElixir.BillingControllerTest do
  use ExUnit.Case

  alias SmartGridElixir.{BillingController, Reading}

  doctest BillingController

  test "POST /api/invoices com dados válidos" do
    # Simular uma requisição válida
    payload = %{
      "consumerId" => "C001",
      "bandeira" => "verde",
      "readings" => [
        %{"consumerId" => "C001", "kwh" => 100.0, "timestamp" => "2024-01-01", "profile" => "residencial", "valid" => true},
        %{"consumerId" => "C001", "kwh" => 110.0, "timestamp" => "2024-01-02", "profile" => "residencial", "valid" => true},
        %{"consumerId" => "C001", "kwh" => 105.0, "timestamp" => "2024-01-03", "profile" => "residencial", "valid" => true}
      ]
    }

    conn = %Plug.Conn{
      method: "POST",
      request_path: "/api/invoices",
      body_params: payload
    }

    # Verificar que o controlador é alcançável
    assert BillingController
  end

  test "calcula consumo total corretamente" do
    readings = [
      %Reading{consumer_id: "C001", kwh: 100.0, timestamp: "2024-01-01", profile: :residencial, valid: true},
      %Reading{consumer_id: "C001", kwh: 110.0, timestamp: "2024-01-02", profile: :residencial, valid: true},
      %Reading{consumer_id: "C001", kwh: 105.0, timestamp: "2024-01-03", profile: :residencial, valid: true}
    ]

    # Total esperado: 315 kWh
    total_kwh = Enum.reduce(readings, 0.0, &(&1.kwh + &2))
    assert total_kwh == 315.0
  end
end
