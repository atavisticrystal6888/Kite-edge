defmodule KiteEdgeWeb.InstrumentsController do
  @moduledoc "T074b: Instrument search, quote, and OHLCV routes."
  use KiteEdgeWeb, :controller

  alias KiteEdge.Market.InstrumentQuery

  def search(conn, %{"query" => q} = params) do
    limit = case Integer.parse(params["limit"] || "20") do
      {n, _} when n > 0 and n <= 100 -> n
      _ -> 20
    end
    results = InstrumentQuery.search(q,
      exchange: params["exchange"],
      limit: limit
    )
    json(conn, %{results: results})
  end

  def quote(conn, %{"symbol" => symbol} = params) do
    exchange = params["exchange"] || "NSE"
    case InstrumentQuery.quote(symbol, exchange) do
      {:ok, data} -> json(conn, %{data: data})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "Instrument not found"})
    end
  end

  def ohlcv(conn, %{"symbol" => symbol} = params) do
    case InstrumentQuery.ohlcv(
      symbol,
      params["timeframe"] || "1d",
      params["from"],
      params["to"],
      params["exchange"] || "NSE"
    ) do
      {:ok, data} -> json(conn, data)
      {:error, reason} -> conn |> put_status(400) |> json(%{error: reason})
    end
  end
end
