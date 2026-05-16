defmodule KiteEdge.Portfolio.Summary do
  @moduledoc """
  Portfolio-level summary aggregation.

  Returns total invested, current market value, absolute P&L, and day change.
  """

  alias KiteEdge.Portfolio.OfflineMode

  @spec build([map()]) :: map()
  def build(holdings) do
    invested =
      Enum.reduce(holdings, Decimal.new(0), fn h, acc ->
        Decimal.add(acc, Decimal.mult(Decimal.new(h.quantity), h.average_price))
      end)

    current =
      Enum.reduce(holdings, Decimal.new(0), fn h, acc ->
        price = h.last_price || h.average_price
        Decimal.add(acc, Decimal.mult(Decimal.new(h.quantity), price))
      end)

    pnl = Decimal.sub(current, invested)

    day_change =
      Enum.reduce(holdings, Decimal.new(0), fn h, acc ->
        Decimal.add(acc, h.day_change || Decimal.new(0))
      end)

    synced_at = holdings |> Enum.map(&Map.get(&1, :synced_at)) |> Enum.max(DateTime, fn -> nil end)

    %{
      invested: invested,
      current_value: current,
      pnl: pnl,
      day_change: day_change,
      pnl_percent: percent(pnl, invested),
      freshness: OfflineMode.freshness(synced_at),
      synced_at: synced_at
    }
  end

  defp percent(_, %Decimal{coef: 0}), do: 0.0
  defp percent(n, d), do: n |> Decimal.div(d) |> Decimal.to_float()
end
