defmodule KiteEdge.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KiteEdge.Repo,
      {Phoenix.PubSub, name: KiteEdge.PubSub},
      {Finch, name: KiteEdge.Finch},
      {Cachex, name: :kite_edge_cache},
      KiteEdge.Kite.RateLimiter,
      KiteEdge.Kite.SessionStore,
      {Oban, Application.fetch_env!(:kite_edge, Oban)}
    ]

    opts = [strategy: :one_for_one, name: KiteEdge.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
