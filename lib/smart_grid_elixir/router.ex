defmodule SmartGridElixir.Router do
  @moduledoc """
  Router HTTP para a API de faturamento de energia.

  Endpoints:
  - POST /api/invoices - Processa leituras e gera fatura
  """

  use Plug.Router

  plug :match
  plug :dispatch

  def match(conn, opts) do
    Plug.Conn.put_private(conn, :plug_skip_csrf_protection, true)
    |> super(opts)
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{"error" => "Not found"}))
  end

  def dispatch(%{method: "POST", path_info: ["api", "invoices"]} = conn, _opts) do
    SmartGridElixir.BillingController.create(conn, %{})
  end

  def dispatch(%{method: "GET", path_info: ["health"]} = conn, _opts) do
    send_resp(conn, 200, Jason.encode!(%{"status" => "ok"}))
  end

  def dispatch(conn, _opts) do
    send_resp(conn, 404, Jason.encode!(%{"error" => "Endpoint not found"}))
  end
end
