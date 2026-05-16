defmodule KiteEdge.Portfolio.DividendSummary do
  @moduledoc "Aggregates dividends by tradingsymbol and overall total."

  @spec aggregate([map()]) :: %{per_symbol: %{String.t() => Decimal.t()}, total: Decimal.t()}
  def aggregate(entries) do
    per_symbol =
      entries
      |> Enum.group_by(& &1.tradingsymbol)
      |> Map.new(fn {sym, rows} ->
        {sym,
         Enum.reduce(rows, Decimal.new(0), fn r, acc -> Decimal.add(acc, r.amount) end)}
      end)

    total =
      per_symbol
      |> Map.values()
      |> Enum.reduce(Decimal.new(0), &Decimal.add/2)

    %{per_symbol: per_symbol, total: total}
  end
end
