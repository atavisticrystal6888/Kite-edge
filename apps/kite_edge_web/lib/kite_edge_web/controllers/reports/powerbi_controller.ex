defmodule KiteEdgeWeb.Reports.PowerBIController do
  @moduledoc "T177a: Power BI streaming dataset push endpoint."
  use KiteEdgeWeb, :controller

  alias KiteEdge.Portfolio.HoldingsQuery

  def push(conn, _params) do
    %{data: holdings} = HoldingsQuery.list()

    # Power BI streaming dataset format: array of rows
    rows =
      Enum.map(holdings, fn h ->
        %{
          tradingsymbol: h[:tradingsymbol] || h["tradingsymbol"],
          exchange: h[:exchange] || h["exchange"],
          quantity: h[:quantity] || h["quantity"],
          average_price: h[:average_price] || h["average_price"],
          last_price: h[:last_price] || h["last_price"],
          pnl: h[:pnl] || h["pnl"],
          sector: h[:sector] || h["sector"],
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
        }
      end)

    json(conn, rows)
  end
end
