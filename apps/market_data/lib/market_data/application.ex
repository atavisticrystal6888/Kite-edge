defmodule MarketData.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MarketData.TickPublisher,
      MarketData.KiteTicker.Connection
    ]

    opts = [strategy: :one_for_one, name: MarketData.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
