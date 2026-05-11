defmodule SmartGridElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :smart_grid_elixir,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Data validation and utilities
      {:decimal, "~> 2.1"},

      # Optional: for future web integration
      {:plug_cowboy, "~> 2.6", optional: true},

      # Development/debugging
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
