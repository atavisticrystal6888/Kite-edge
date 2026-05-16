defmodule KiteEdge.Portfolio.Composition do
  @moduledoc """
  Pure calculators for portfolio composition views.

  Inputs are holding maps (produced by `HoldingsQuery`) so this module is
  trivially testable in isolation.
  """

  @spec by_sector([map()]) :: [%{sector: String.t(), value: Decimal.t(), weight: float()}]
  def by_sector(holdings) do
    total_value = total_value(holdings)

    holdings
    |> Enum.group_by(&(&1.sector || "Unclassified"))
    |> Enum.map(fn {sector, rows} ->
      value = sum_values(rows)

      %{
        sector: sector,
        value: value,
        weight: safe_weight(value, total_value)
      }
    end)
    |> Enum.sort_by(& &1.weight, :desc)
  end

  defp total_value(holdings) do
    Enum.reduce(holdings, Decimal.new(0), fn h, acc -> Decimal.add(acc, holding_value(h)) end)
  end

  defp sum_values(rows) do
    Enum.reduce(rows, Decimal.new(0), fn h, acc -> Decimal.add(acc, holding_value(h)) end)
  end

  defp holding_value(%{quantity: q, last_price: p}) when not is_nil(p) do
    Decimal.mult(Decimal.new(q), p)
  end

  defp holding_value(_), do: Decimal.new(0)

  defp safe_weight(_value, %Decimal{coef: 0}), do: 0.0

  defp safe_weight(value, total) do
    value |> Decimal.div(total) |> Decimal.to_float()
  end
end
