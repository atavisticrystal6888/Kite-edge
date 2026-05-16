defmodule KiteEdge.Sync.TradesSync do
  @moduledoc """
  Synchronizes orders and trades from Kite.

  Kite's `/trades` endpoint returns only the current trading day; full
  history is reconstructed by merging today's trades with the locally
  stored history (`TradeHistorySync` performs deeper backfill).
  """
  use Oban.Worker, queue: :kite_sync, max_attempts: 5

  alias KiteEdge.Kite.Client
  alias KiteEdge.Repo
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"access_token" => token}}), do: sync(access_token: token)

  @spec sync(keyword()) :: :ok | {:error, term()}
  def sync(opts) do
    case Client.get("/trades", opts) do
      {:ok, %{"data" => trades}} ->
        Enum.each(trades, &upsert_trade/1)
        :ok

      {:error, reason} = err ->
        Logger.error("trades sync failed: #{inspect(reason)}")
        err
    end
  end

  defp upsert_trade(row) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    attrs = %{
      kite_trade_id: row["trade_id"],
      tradingsymbol: row["tradingsymbol"],
      exchange: row["exchange"],
      transaction_type: row["transaction_type"],
      product: row["product"],
      quantity: row["quantity"],
      price: row["average_price"],
      order_id: row["order_id"],
      exchange_order_id: row["exchange_order_id"],
      traded_at: parse_time(row["order_timestamp"]) || now,
      inserted_at: now,
      updated_at: now
    }

    Repo.insert_all("trades", [attrs],
      on_conflict: :nothing,
      conflict_target: [:kite_trade_id]
    )
  end

  defp parse_time(nil), do: nil
  defp parse_time(%DateTime{} = dt), do: dt

  defp parse_time(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end
end
