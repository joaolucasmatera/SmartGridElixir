defmodule SmartGridElixir.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: SmartGridElixir.Router, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: SmartGridElixir.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        IO.puts("✓ SmartGrid API started on http://localhost:4000")
        {:ok, pid}

      error ->
        error
    end
  end
end
