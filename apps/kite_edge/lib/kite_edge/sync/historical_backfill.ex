defmodule KiteEdge.Sync.HistoricalBackfill do
  @moduledoc """
  Nightly OHLCV backfill. Iterates tracked instruments and requests daily
  candles from Kite's historical endpoint, respecting the 3 req/sec cap
  via `KiteEdge.Kite.Client`. Longer timeframes (1m, 5m, 15m, 1h) are
  aggregated downstream by the Python pipeline.
  """
  use Oban.Worker, queue: :backfill, max_attempts: 3

  alias KiteEdge.Kite.Client
  alias KiteEdge.Market.InstrumentMaster
  alias KiteEdge.Repo
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"access_token" => token}}), do: run(access_token: token)
  def perform(_job), do: :ok

  def run(opts) do
    InstrumentMaster
    |> Repo.all()
    |> Enum.each(&backfill_instrument(&1, opts))
  end

  defp backfill_instrument(%InstrumentMaster{instrument_token: token}, opts) do
    to = Date.utc_today()
    from = Date.add(to, -365)
    path = "/instruments/historical/#{token}/day?from=#{from}&to=#{to}"

    case Client.get(path, opts) do
      {:ok, %{"data" => %{"candles" => candles}}} ->
        # Persistence happens in a dedicated OHLCV writer in Phase 4.
        Logger.debug("backfilled #{length(candles)} candles for token #{token}")

      {:error, reason} ->
        Logger.warning("backfill skipped for #{token}: #{inspect(reason)}")
    end
  end
end
