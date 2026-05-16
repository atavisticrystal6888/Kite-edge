defmodule KiteEdgeWeb.Analytics.RiskController do
  @moduledoc "T104: Gateway proxy for risk analytics endpoints."
  use KiteEdgeWeb, :controller

  @analytics_url Application.compile_env(:kite_edge_web, :analytics_engine_url, "http://localhost:8000")

  def portfolio(conn, params) do
    proxy_post(conn, "/api/v1/analytics/risk/portfolio", params)
  end

  def var(conn, params) do
    proxy_post(conn, "/api/v1/analytics/risk/var", params)
  end

  def montecarlo(conn, params) do
    proxy_post(conn, "/api/v1/analytics/risk/montecarlo", params)
  end

  def stress_test(conn, params) do
    proxy_post(conn, "/api/v1/analytics/risk/stress-test", params)
  end

  def correlation(conn, params) do
    proxy_post(conn, "/api/v1/analytics/risk/correlation", params)
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
