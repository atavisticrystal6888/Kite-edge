defmodule KiteEdge.MixProject do
  @moduledoc """
  Core domain application for KiteEdge.

  Owns persistence (Ecto/Postgres), Kite API client (pacing, retry, session
  storage in Redis), portfolio/holding/position/trade sync, historical OHLCV
  backfill, and settings (indicator profiles, notification preferences,
  watchlists).
  """
  use Mix.Project

  def project do
    [
      app: :kite_edge,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {KiteEdge.Application, []},
      extra_applications: [:logger, :runtime_tools, :crypto, :ssl]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Persistence
      {:ecto_sql, "~> 3.11"},
      {:postgrex, "~> 0.17"},
      # Background jobs / schedulers
      {:oban, "~> 2.17"},
      # Redis client for ephemeral state, rate limiting, LTP cache
      {:redix, "~> 1.5"},
      # HTTP client for Kite API
      {:tesla, "~> 1.8"},
      {:finch, "~> 0.18"},
      {:jason, "~> 1.4"},
      # Caching
      {:cachex, "~> 3.6"},
      # Kafka producer for outbound tick / alert events
      # {:brod, "~> 3.16"},  # Temporarily disabled: rebar3 TLS issue
      # Observability
      {:telemetry, "~> 1.2"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      # Error tracking
      {:sentry, "~> 10.2"},
      {:hackney, "~> 1.20"},
      # Optional email transport (wired by notification app, kept shared here)
      {:swoosh, "~> 1.16"},
      # Test helpers
      {:mox, "~> 1.1", only: :test},
      {:ex_machina, "~> 2.7", only: :test}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
