defmodule KiteEdgeWeb.PortfolioChannel do
  @moduledoc """
  `portfolio:live` channel.

  On join, sends a snapshot of current holdings and subscribes to the
  `market.ticks` PubSub topic. Every tick for a held instrument is pushed
  to the client so the dashboard can recompute P&L without a round-trip.
  """
  use KiteEdgeWeb, :channel

  alias KiteEdge.Portfolio.HoldingsQuery

  @impl true
  def join("portfolio:live", _params, socket) do
    :ok = Phoenix.PubSub.subscribe(KiteEdge.PubSub, "market.ticks")
    send(self(), :snapshot)
    {:ok, socket}
  end

  @impl true
  def handle_info(:snapshot, socket) do
    push(socket, "snapshot", HoldingsQuery.list())
    {:noreply, socket}
  end

  def handle_info({:tick, tick}, socket) do
    push(socket, "tick", tick)
    {:noreply, socket}
  end
end
