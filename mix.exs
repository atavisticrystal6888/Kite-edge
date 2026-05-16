defmodule KiteEdge.Umbrella.MixProject do
  @moduledoc """
  KiteEdge umbrella project root.

  Hosts the four Elixir applications that make up the gateway and market-data
  plane: `kite_edge`, `kite_edge_web`, `market_data`, and `notification`.
  Python (`analytics_engine/`, `data_pipeline/`) and the React dashboard
  (`dashboard/`) live alongside this umbrella and are orchestrated via
  `docker-compose.yml`.
  """
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: releases(),
      preferred_cli_env: [
        "test.all": :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp deps do
    [
      # {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      # {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      # {:excoveralls, "~> 0.18", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": [
        "cmd --app kite_edge mix ecto.create",
        "cmd --app kite_edge mix ecto.migrate",
        "cmd --app kite_edge mix run priv/repo/seeds.exs"
      ],
      "ecto.reset": [
        "cmd --app kite_edge mix ecto.drop",
        "ecto.setup"
      ],
      "test.all": ["cmd mix test"],
      lint: ["format --check-formatted", "credo --strict"]
    ]
  end

  defp releases do
    [
      kite_edge: [
        version: "0.1.0",
        applications: [
          kite_edge: :permanent,
          kite_edge_web: :permanent,
          market_data: :permanent,
          notification: :permanent
        ],
        include_executables_for: [:unix]
      ]
    ]
  end
end
