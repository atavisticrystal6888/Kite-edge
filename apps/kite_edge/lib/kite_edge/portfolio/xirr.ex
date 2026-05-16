defmodule KiteEdge.Portfolio.Xirr do
  @moduledoc """
  Thin wrapper that defers XIRR computation to the Python analytics engine
  over HTTP. The Python `scipy.optimize.brentq` implementation is the
  canonical reference used by the specification.

  The wrapper is kept in Elixir so controllers can compose portfolio
  responses without crossing language boundaries in their request path.
  """

  @spec compute([%{amount: Decimal.t(), date: Date.t()}]) :: {:ok, float()} | {:error, term()}
  def compute(cashflows) when is_list(cashflows) and length(cashflows) >= 2 do
    url = Application.get_env(:kite_edge, :analytics_engine_url, "http://analytics_engine:8001")

    body =
      Jason.encode!(%{
        cashflows:
          Enum.map(cashflows, fn c ->
            %{amount: Decimal.to_float(c.amount), date: Date.to_iso8601(c.date)}
          end)
      })

    request = Finch.build(:post, "#{url}/portfolio/xirr", [{"content-type", "application/json"}], body)

    case Finch.request(request, KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200, body: json}} ->
        {:ok, Jason.decode!(json)["rate"]}

      other ->
        {:error, other}
    end
  end

  def compute(_), do: {:error, :insufficient_cashflows}
end
