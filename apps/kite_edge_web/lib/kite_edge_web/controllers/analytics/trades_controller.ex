defmodule KiteEdgeWeb.Analytics.TradesController do
  @moduledoc "T146: Gateway proxy for trade analytics endpoints."
  use KiteEdgeWeb, :controller

  @analytics_url Application.compile_env(:kite_edge_web, :analytics_engine_url, "http://localhost:8000")

  def performance(conn, params) do
    qs = URI.encode_query(Map.take(params, ["from", "to", "group_by"]))
    case Finch.build(:get, "#{@analytics_url}/api/v1/analytics/trades/performance?#{qs}", [])
         |> Finch.request(KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200, body: resp}} -> json(conn, Jason.decode!(resp))
      {:ok, %Finch.Response{status: s}} -> conn |> put_status(502) |> json(%{error: "upstream_#{s}"})
      {:error, reason} -> conn |> put_status(502) |> json(%{error: inspect(reason)})
    end
  end
end
