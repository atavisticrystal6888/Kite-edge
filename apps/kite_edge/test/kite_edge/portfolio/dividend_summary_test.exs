defmodule KiteEdge.Portfolio.DividendSummaryTest do
  @moduledoc "T041: dividend aggregation regression tests."
  use ExUnit.Case, async: true

  alias KiteEdge.Portfolio.DividendSummary

  test "aggregates per-instrument dividend totals" do
    entries = [
      %{tradingsymbol: "RELIANCE", amount: Decimal.new("80"), ex_date: ~D[2025-08-15]},
      %{tradingsymbol: "RELIANCE", amount: Decimal.new("90"), ex_date: ~D[2026-02-10]},
      %{tradingsymbol: "INFY", amount: Decimal.new("30"), ex_date: ~D[2025-10-01]}
    ]

    %{per_symbol: per, total: total} = DividendSummary.aggregate(entries)

    assert Decimal.equal?(per["RELIANCE"], Decimal.new("170"))
    assert Decimal.equal?(per["INFY"], Decimal.new("30"))
    assert Decimal.equal?(total, Decimal.new("200"))
  end
end
