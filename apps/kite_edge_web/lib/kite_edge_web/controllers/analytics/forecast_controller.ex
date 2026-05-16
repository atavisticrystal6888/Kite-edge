defmodule KiteEdgeWeb.Analytics.ForecastController do
  @moduledoc "T127: Gateway proxy for forecast endpoints."
  use KiteEdgeWeb, :controller

  @analytics_url Application.compile_env(:kite_edge_web, :analytics_engine_url, "http://localhost:8000")

  def instrument(conn, %{"symbol" => symbol} = params) do
    body = Map.drop(params, ["symbol"])
    proxy_post(conn, "/api/v1/analytics/forecast/#{symbol}", body)
  end

  def portfolio(conn, params) do
    proxy_post(conn, "/api/v1/analytics/forecast/portfolio", params)
  end

  defp proxy_post(conn, path, body) do
    case Finch.build(:post, "#{@analytics_url}#{path}", [{"content-type", "application/json"}], Jason.encode!(body))
         |> Finch.request(KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200, body: resp}} -> json(conn, Jason.decode!(resp))
      {:ok, %Finch.Response{status: s}} -> conn |> put_status(502) |> json(%{error: "upstream_#{s}"})
      {:error, reason} -> conn |> put_status(502) |> json(%{error: inspect(reason)})
    end
  end
end
