defmodule KiteEdge.Portfolio.MarketCapDistribution do
  @moduledoc "Aggregates holdings by market-cap tier (large/mid/small/unknown)."

  @spec aggregate([map()]) :: [%{tier: String.t(), value: Decimal.t(), weight: float()}]
  def aggregate(holdings) do
    total = Enum.reduce(holdings, Decimal.new(0), &Decimal.add(&2, value(&1)))

    holdings
    |> Enum.group_by(&tier_of/1)
    |> Enum.map(fn {tier, rows} ->
      v = Enum.reduce(rows, Decimal.new(0), &Decimal.add(&2, value(&1)))
      %{tier: tier, value: v, weight: weight(v, total)}
    end)
    |> Enum.sort_by(& &1.weight, :desc)
  end

  defp tier_of(%{market_cap_tier: t}) when is_binary(t) and t != "", do: t
  defp tier_of(_), do: "unknown"

  defp value(%{quantity: q, last_price: p}) when not is_nil(p),
    do: Decimal.mult(Decimal.new(q), p)

  defp value(_), do: Decimal.new(0)

  defp weight(_, %Decimal{coef: 0}), do: 0.0
  defp weight(v, t), do: v |> Decimal.div(t) |> Decimal.to_float()
end
