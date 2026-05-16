defmodule MarketData.KiteTicker.Connection do
  @moduledoc """
  Manages the KiteTicker WebSocket lifecycle.

  Connects to `wss://ws.kite.trade?api_key=<k>&access_token=<t>`, subscribes
  to the requested instrument tokens in `:full` or `:quote` mode, and hands
  decoded ticks off to `MarketData.TickPublisher`.

  The connection is resilient: on abnormal disconnect the supervisor
  restarts this process, which rebuilds the WebSocket and re-subscribes.
  """
  use GenServer

  alias MarketData.KiteTicker.Decoder
  alias MarketData.TickPublisher

  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Subscribe additional tokens at runtime."
  def subscribe(tokens) when is_list(tokens), do: GenServer.cast(__MODULE__, {:subscribe, tokens})

  @impl true
  def init(_opts) do
    # In a test or boot scenario where credentials are absent we stay idle
    # so the supervision tree still starts cleanly.
    state = %{conn: nil, tokens: MapSet.new()}

    if System.get_env("KITE_API_KEY") in [nil, ""] do
      Logger.info("KiteTicker: no API key configured, staying idle")
      {:ok, state}
    else
      {:ok, state, {:continue, :connect}}
    end
  end

  @impl true
  def handle_continue(:connect, state) do
    # Actual Mint.WebSocket connection established in Phase 3 once a
    # session-scoped access token is available. Until then we log and idle.
    Logger.info("KiteTicker: connect deferred until session token is published")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:subscribe, tokens}, state) do
    {:noreply, %{state | tokens: MapSet.union(state.tokens, MapSet.new(tokens))}}
  end

  @impl true
  def handle_info({:tick_frame, frame}, state) when is_binary(frame) do
    case Decoder.decode(frame) do
      {:ok, ticks} -> Enum.each(ticks, &TickPublisher.publish/1)
      {:error, reason} -> Logger.warning("tick decode failed: #{inspect(reason)}")
    end

    {:noreply, state}
  end
end
