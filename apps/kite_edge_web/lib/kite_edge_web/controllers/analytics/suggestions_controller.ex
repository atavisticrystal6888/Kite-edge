defmodule KiteEdgeWeb.Analytics.SuggestionsController do
  @moduledoc "T165: Gateway proxy for suggestion endpoints."
  use KiteEdgeWeb, :controller

  @analytics_url Application.compile_env(:kite_edge_web, :analytics_engine_url, "http://localhost:8000")

  def signals(conn, params) do
    qs = URI.encode_query(Map.take(params, ["scope", "limit"]))
    case Finch.build(:get, "#{@analytics_url}/api/v1/analytics/signals?#{qs}", [])
         |> Finch.request(KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200, body: resp}} -> json(conn, Jason.decode!(resp))
      {:ok, %Finch.Response{status: s}} -> conn |> put_status(502) |> json(%{error: "upstream_#{s}"})
      {:error, reason} -> conn |> put_status(502) |> json(%{error: inspect(reason)})
    end
  end

  def rebalance(conn, params) do
    case Finch.build(:post, "#{@analytics_url}/api/v1/analytics/rebalance", [{"content-type", "application/json"}], Jason.encode!(params))
         |> Finch.request(KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200, body: resp}} -> json(conn, Jason.decode!(resp))
      {:ok, %Finch.Response{status: s}} -> conn |> put_status(502) |> json(%{error: "upstream_#{s}"})
      {:error, reason} -> conn |> put_status(502) |> json(%{error: inspect(reason)})
    end
  end
end
