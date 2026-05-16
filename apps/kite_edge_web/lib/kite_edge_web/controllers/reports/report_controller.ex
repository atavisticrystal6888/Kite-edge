defmodule KiteEdgeWeb.Reports.ReportController do
  @moduledoc "T180: Gateway proxy for report endpoints."
  use KiteEdgeWeb, :controller

  @analytics_url Application.compile_env(:kite_edge_web, :analytics_engine_url, "http://localhost:8000")

  def tearsheet(conn, params) do
    proxy_post(conn, "/api/v1/reports/tearsheet", params)
  end

  def export(conn, params) do
    proxy_post(conn, "/api/v1/reports/export", params)
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
