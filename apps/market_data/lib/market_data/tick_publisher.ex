defmodule MarketData.TickPublisher do
  @moduledoc """
  Fans decoded ticks out to:
    * Kafka topic `market.ticks` (downstream candle builder, analytics triggers)
    * Redis quote cache key `kiteedge:ltp:<token>` (fast portfolio recompute)

  Fire-and-forget: tick loss is acceptable (market data is replayable via
  historical candles). We never block the KiteTicker connection on the
  downstream sinks.
  """
  use GenServer

  require Logger

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @spec publish(map()) :: :ok
  def publish(tick) when is_map(tick), do: GenServer.cast(__MODULE__, {:publish, tick})

  @impl true
  def init(_), do: {:ok, %{redis: nil}}

  @impl true
  def handle_cast({:publish, tick}, state) do
    publish_to_kafka(tick)
    publish_to_redis(tick, state)
    {:noreply, state}
  end

  defp publish_to_kafka(tick) do
    try do
      payload = Jason.encode!(tick)
      :brod.produce_no_ack(:kite_edge_brod_client, "market.ticks", :random, "", payload)
    rescue
      e -> Logger.debug("kafka publish skipped: #{inspect(e)}")
    end
  end

  defp publish_to_redis(%{instrument_token: token, last_price: ltp}, _state) do
    try do
      Redix.noreply_command(:kite_edge_redix_quote, [
        "SET",
        "kiteedge:ltp:#{token}",
        Float.to_string(ltp * 1.0),
        "EX",
        "60"
      ])
    rescue
      e -> Logger.debug("redis publish skipped: #{inspect(e)}")
    end
  end

  defp publish_to_redis(_, _), do: :ok
end
