defmodule KiteEdge.Portfolio.HoldingReturns do
  @moduledoc """
  Per-holding absolute and percentage returns.

  Absolute return  = (last_price - average_price) * quantity
  Percentage return = (last_price - average_price) / average_price
  """

  @spec compute(map()) :: %{absolute: Decimal.t(), percent: float()}
  def compute(%{quantity: q, average_price: avg, last_price: last})
      when not is_nil(avg) and not is_nil(last) do
    diff = Decimal.sub(last, avg)
    absolute = Decimal.mult(Decimal.new(q), diff)

    percent =
      case Decimal.compare(avg, Decimal.new(0)) do
        :eq -> 0.0
        _ -> diff |> Decimal.div(avg) |> Decimal.to_float()
      end

    %{absolute: absolute, percent: percent}
  end

  def compute(_), do: %{absolute: Decimal.new(0), percent: 0.0}
end
