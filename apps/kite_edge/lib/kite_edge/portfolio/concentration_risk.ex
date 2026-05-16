defmodule KiteEdge.Portfolio.ConcentrationRisk do
  @moduledoc """
  Concentration-risk indicators.

  Computes:
    * Top N weight (default N=5)
    * Herfindahl-Hirschman Index over holding weights (0-1, higher = more concentrated)
  """

  @default_top_n 5

  @spec analyze([map()], keyword()) :: %{
          top_n_weight: float(),
          hhi: float(),
          top_holdings: [%{tradingsymbol: String.t(), weight: float()}]
        }
  def analyze(holdings, opts \\ []) do
    n = Keyword.get(opts, :top_n, @default_top_n)
    weights = weights(holdings)

    top_holdings =
      weights
      |> Enum.sort_by(& &1.weight, :desc)
      |> Enum.take(n)

    %{
      top_n_weight: top_holdings |> Enum.map(& &1.weight) |> Enum.sum(),
      hhi: hhi(weights),
      top_holdings: top_holdings
    }
  end

  defp weights(holdings) do
    total =
      holdings
      |> Enum.map(&value/1)
      |> Enum.reduce(0.0, &Kernel.+/2)

    Enum.map(holdings, fn h ->
      %{
        tradingsymbol: h.tradingsymbol,
        weight: if(total > 0, do: value(h) / total, else: 0.0)
      }
    end)
  end

  defp value(%{quantity: q, last_price: p}) when not is_nil(p) do
    Decimal.to_float(Decimal.mult(Decimal.new(q), p))
  end

  defp value(_), do: 0.0

  defp hhi(weights), do: Enum.reduce(weights, 0.0, fn %{weight: w}, acc -> acc + w * w end)
end
