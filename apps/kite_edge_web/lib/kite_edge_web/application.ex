defmodule KiteEdgeWeb.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KiteEdgeWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: KiteEdgeWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    KiteEdgeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
