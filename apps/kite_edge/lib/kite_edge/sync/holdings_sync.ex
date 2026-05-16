defmodule KiteEdge.Sync.HoldingsSync do
  @moduledoc """
  Synchronizes holdings and positions from Kite into PostgreSQL.
  Idempotent upsert on (tradingsymbol, exchange) for holdings and
  (tradingsymbol, exchange, product) for positions.
  """
  use Oban.Worker, queue: :kite_sync, max_attempts: 5

  alias KiteEdge.Kite.Client
  alias KiteEdge.Market.InstrumentMaster
  alias KiteEdge.Portfolio.{Holding, Position}
  alias KiteEdge.Repo

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"access_token" => token}}), do: sync(access_token: token)

  @spec sync(keyword()) :: :ok | {:error, term()}
  def sync(opts) do
    with {:ok, %{"data" => holdings}} <- Client.get("/portfolio/holdings", opts),
         {:ok, %{"data" => positions}} <- Client.get("/portfolio/positions", opts) do
      Repo.transaction(fn ->
        Enum.each(holdings, &upsert_holding/1)
        Enum.each(Map.get(positions, "net", []), &upsert_position/1)
      end)

      :ok
    else
      {:error, reason} = err ->
        Logger.error("holdings sync failed: #{inspect(reason)}")
        err
    end
  end

  defp upsert_holding(h) do
    instrument = resolve_instrument!(h)
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    attrs = %{
      instrument_id: instrument.id,
      tradingsymbol: h["tradingsymbol"],
      exchange: h["exchange"],
      quantity: h["quantity"],
      average_price: to_decimal(h["average_price"]),
      last_price: to_decimal(h["last_price"]),
      pnl: to_decimal(h["pnl"]),
      close_price: to_decimal(h["close_price"]),
      day_change: to_decimal(h["day_change"]),
      day_change_pct: to_decimal(h["day_change_percentage"]),
      collateral_quantity: h["collateral_quantity"] || 0,
      collateral_type: h["collateral_type"],
      isin: h["isin"],
      synced_at: now
    }

    case Repo.get_by(Holding, tradingsymbol: h["tradingsymbol"], exchange: h["exchange"]) do
      nil -> %Holding{} |> Holding.changeset(attrs) |> Repo.insert!()
      existing -> existing |> Holding.changeset(attrs) |> Repo.update!()
    end
  end

  defp upsert_position(p) do
    instrument = resolve_instrument!(p)
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    attrs = %{
      instrument_id: instrument.id,
      tradingsymbol: p["tradingsymbol"],
      exchange: p["exchange"],
      product: p["product"],
      quantity: p["quantity"],
      average_price: to_decimal(p["average_price"]),
      last_price: to_decimal(p["last_price"]),
      pnl: to_decimal(p["pnl"]),
      m2m: to_decimal(p["m2m"]),
      buy_quantity: p["buy_quantity"] || 0,
      buy_value: to_decimal(p["buy_value"]),
      sell_quantity: p["sell_quantity"] || 0,
      sell_value: to_decimal(p["sell_value"]),
      segment: p["segment"],
      synced_at: now
    }

    case Repo.get_by(Position,
           tradingsymbol: p["tradingsymbol"],
           exchange: p["exchange"],
           product: p["product"]
         ) do
      nil -> %Position{} |> Position.changeset(attrs) |> Repo.insert!()
      existing -> existing |> Position.changeset(attrs) |> Repo.update!()
    end
  end

  defp resolve_instrument!(%{"instrument_token" => token} = row) when is_integer(token) do
    case Repo.get_by(InstrumentMaster, instrument_token: token) do
      nil ->
        %InstrumentMaster{}
        |> InstrumentMaster.changeset(%{
          instrument_token: token,
          exchange: row["exchange"],
          tradingsymbol: row["tradingsymbol"]
        })
        |> Repo.insert!()

      found ->
        found
    end
  end

  defp to_decimal(nil), do: nil
  defp to_decimal(%Decimal{} = d), do: d
  defp to_decimal(n) when is_number(n), do: Decimal.from_float(n * 1.0)
  defp to_decimal(s) when is_binary(s), do: Decimal.new(s)
end
