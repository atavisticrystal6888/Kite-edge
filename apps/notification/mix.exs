defmodule Notification.MixProject do
  @moduledoc """
  Notification application.

  Consumes `alerts.fired` from Kafka via Broadway, persists alert history,
  delivers real-time in-app events through Phoenix PubSub, and (optionally)
  dispatches email via Swoosh when the user has opted in.
  """
  use Mix.Project

  def project do
    [
      app: :notification,
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
      mod: {Notification.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:kite_edge, in_umbrella: true},
      {:broadway, "~> 1.1"},
      # {:broadway_kafka, "~> 0.4"},  # Temporarily disabled: rebar3 TLS issue in corporate network
      {:phoenix_pubsub, "~> 2.1"},
      {:swoosh, "~> 1.16"},
      {:gen_smtp, "~> 1.2"},
      {:jason, "~> 1.4"}
    ]
  end
end
