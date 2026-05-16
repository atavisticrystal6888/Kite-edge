defmodule MarketData.MixProject do
  @moduledoc """
  Market Data application.

  Owns the KiteTicker WebSocket lifecycle, decoding of binary tick frames,
  Kafka publishing of `market.ticks`, and Redis quote-cache updates. Isolated
  from the gateway so a ticker restart never interrupts HTTP.
  """
  use Mix.Project

  def project do
    [
      app: :market_data,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {MarketData.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:kite_edge, in_umbrella: true},
      {:mint_web_socket, "~> 1.0"},
      # {:brod, "~> 3.16"},  # Temporarily disabled: rebar3 TLS issue
      {:redix, "~> 1.5"},
      {:jason, "~> 1.4"},
      {:telemetry, "~> 1.2"}
    ]
  end
end
