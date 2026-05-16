defmodule KiteEdge.Portfolio.HoldingsQuery do
  @moduledoc """
  Read model for the holdings endpoint.

  Joins `holdings_current` with `instrument_masters` and adds a freshness
  classification so the dashboard can render a stale-data badge.
  """
  import Ecto.Query

  alias KiteEdge.Portfolio.{Holding, OfflineMode}
  alias KiteEdge.Repo

  @spec list() :: %{data: [map()], freshness: atom(), synced_at: DateTime.t() | nil}
  def list do
    rows =
      from(h in Holding,
        preload: [:instrument],
        order_by: [desc: h.pnl]
      )
      |> Repo.all()

    synced_at = rows |> Enum.map(& &1.synced_at) |> Enum.max(DateTime, fn -> nil end)

    %{
      data: Enum.map(rows, &serialize/1),
      freshness: OfflineMode.freshness(synced_at),
      synced_at: synced_at
    }
  end

  defp serialize(%Holding{} = h) do
    %{
      tradingsymbol: h.tradingsymbol,
      exchange: h.exchange,
      instrument_token: h.instrument && h.instrument.instrument_token,
      quantity: h.quantity,
      average_price: h.average_price,
      last_price: h.last_price,
      pnl: h.pnl,
      day_change: h.day_change,
      day_change_pct: h.day_change_pct,
      sector: h.instrument && h.instrument.sector
    }
  end
end
