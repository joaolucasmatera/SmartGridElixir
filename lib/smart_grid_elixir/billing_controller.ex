defmodule SmartGridElixir.BillingController do
  @moduledoc """
  Controlador para processar solicitações de faturamento.

  Responsável por:
  - Validar requisições JSON
  - Chamar o Pipeline de processamento
  - Formatar resposta conforme contrato de microserviço
  """

  require Logger

  def create(conn, _params) do
    with {:ok, body, conn} <- read_body(conn),
         {:ok, payload} <- Jason.decode(body),
         {:ok, readings, bandeira, consumer_id} <- extract_params(payload),
         {:ok, invoice, removed_outliers} <- process_readings(readings, bandeira) do
      respond_success(conn, invoice, removed_outliers, consumer_id, bandeira)
    else
      {:error, reason} ->
        respond_error(conn, reason)

      error ->
        Logger.error("Unexpected error: #{inspect(error)}")
        respond_error(conn, "Internal server error")
    end
  end

  defp read_body(conn) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, conn} -> {:ok, body, conn}
      {:more, _body, _conn} -> {:error, "Request body too large"}
      error -> error
    end
  end

  defp extract_params(payload) do
    with true <- is_map(payload),
         consumer_id when is_binary(consumer_id) <- Map.get(payload, "consumerId"),
         bandeira when is_binary(bandeira) <- Map.get(payload, "bandeira"),
         readings when is_list(readings) <- Map.get(payload, "readings") do
      readings_structs = Enum.map(readings, &build_reading/1)
      {:ok, readings_structs, String.to_atom(bandeira), consumer_id}
    else
      _ -> {:error, "Invalid request format"}
    end
  rescue
    _ -> {:error, "Malformed JSON"}
  end

  defp build_reading(reading_data) do
    %SmartGridElixir.Reading{
      consumer_id: Map.get(reading_data, "consumerId", ""),
      kwh: Map.get(reading_data, "kwh", 0.0) |> to_float(),
      timestamp: Map.get(reading_data, "timestamp", ""),
      profile: Map.get(reading_data, "profile", "residencial") |> String.to_atom(),
      valid: Map.get(reading_data, "valid", true)
    }
  end

  defp to_float(value) when is_float(value), do: value
  defp to_float(value) when is_integer(value), do: value / 1
  defp to_float(value) when is_binary(value), do: String.to_float(value)
  defp to_float(_), do: 0.0

  defp process_readings(readings, bandeira) do
    case SmartGridElixir.Pipeline.process_with_details(readings, bandeira) do
      %{invoice: invoice, outliers_removidos: outliers} ->
        {:ok, invoice, outliers}

      error ->
        Logger.error("Pipeline error: #{inspect(error)}")
        {:error, "Failed to process readings"}
    end
  rescue
    e ->
      Logger.error("Pipeline exception: #{inspect(e)}")
      {:error, "Failed to process readings"}
  end

  defp respond_success(conn, invoice, outliers, consumer_id, bandeira) do
    body = %{
      "consumerId" => consumer_id,
      "totalAmount" => Float.round(invoice.total, 2),
      "consumptionKwh" => Float.round(invoice.consumo_kwh, 2),
      "profile" => to_string(invoice.perfil || :residencial),
      "bandeira" => to_string(bandeira),
      "outliers" => outliers,
      "generatedAt" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.send_resp(200, Jason.encode!(body))
  end

  defp respond_error(conn, reason) do
    body = %{"error" => to_string(reason)}

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.send_resp(400, Jason.encode!(body))
  end
end
