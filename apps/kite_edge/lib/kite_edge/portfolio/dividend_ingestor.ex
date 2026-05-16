defmodule KiteEdge.Portfolio.DividendIngestor do
  @moduledoc """
  Normalizes raw Kite dividend/corporate-action entries into the
  canonical `{tradingsymbol, amount, ex_date, record_date}` shape
  consumed by `DividendSummary`.
  """

  @spec normalize([map()]) :: [map()]
  def normalize(entries) when is_list(entries) do
    Enum.map(entries, fn e ->
      %{
        tradingsymbol: e["tradingsymbol"] || e[:tradingsymbol],
        amount: to_decimal(e["amount"] || e[:amount] || 0),
        ex_date: parse_date(e["ex_date"] || e[:ex_date]),
        record_date: parse_date(e["record_date"] || e[:record_date])
      }
    end)
  end

  defp to_decimal(%Decimal{} = d), do: d
  defp to_decimal(n) when is_number(n), do: Decimal.from_float(n * 1.0)
  defp to_decimal(s) when is_binary(s), do: Decimal.new(s)

  defp parse_date(nil), do: nil
  defp parse_date(%Date{} = d), do: d
  defp parse_date(s) when is_binary(s), do: Date.from_iso8601!(s)
end
