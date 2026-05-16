defmodule KiteEdgeWeb.MixProject do
  @moduledoc """
  Phoenix gateway application.

  Terminates HTTP for the dashboard REST surface and Phoenix Channels for
  portfolio:live, ticks:*, alerts:user, and analytics:progress. Proxies
  computation requests to the Python analytics engine.
  """
  use Mix.Project

  def project do
    [
      app: :kite_edge_web,
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
      mod: {KiteEdgeWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:kite_edge, in_umbrella: true},
      {:phoenix, "~> 1.7"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_live_view, "~> 0.20"},
      {:plug_cowboy, "~> 2.7"},
      {:cors_plug, "~> 3.0"},
      {:jason, "~> 1.4"},
      {:open_api_spex, "~> 3.18"},
      {:remote_ip, "~> 1.2"}
    ]
  end
end
