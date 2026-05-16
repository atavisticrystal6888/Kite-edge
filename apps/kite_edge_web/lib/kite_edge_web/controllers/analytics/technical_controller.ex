defmodule KiteEdgeWeb.Analytics.TechnicalController do
  @moduledoc "T075: Gateway proxy for technical analysis endpoints."
  use KiteEdgeWeb, :controller

  @analytics_url Application.compile_env(:kite_edge_web, :analytics_engine_url, "http://localhost:8000")

  def analyze(conn, %{"symbol" => symbol} = params) do
    body = %{
      exchange: params["exchange"] || "NSE",
      timeframes: params["timeframes"] || ["1d"],
      parameter_profile: params["parameter_profile"] || "default",
      include_patterns: params["include_patterns"] != "false",
      include_support_resistance: params["include_support_resistance"] != "false"
    }

    case proxy_post("/api/v1/analytics/technical/#{symbol}", body) do
      {:ok, result} -> json(conn, result)
      {:error, reason} -> conn |> put_status(502) |> json(%{error: reason})
    end
  end

  def summary(conn, %{"symbol" => symbol} = params) do
    qs = URI.encode_query(%{
      timeframe: params["timeframe"] || "1d",
      exchange: params["exchange"] || "NSE"
    })
    case proxy_get("/api/v1/analytics/technical/#{symbol}/summary?#{qs}") do
      {:ok, result} -> json(conn, result)
      {:error, reason} -> conn |> put_status(502) |> json(%{error: reason})
    end
  end

  defp proxy_post(path, body) do
    case Finch.build(:post, "#{@analytics_url}#{path}", [{"content-type", "application/json"}], Jason.encode!(body))
         |> Finch.request(KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200, body: resp}} -> {:ok, Jason.decode!(resp)}
      {:ok, %Finch.Response{status: s}} -> {:error, "upstream_#{s}"}
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  defp proxy_get(path) do
    case Finch.build(:get, "#{@analytics_url}#{path}", []) |> Finch.request(KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200, body: resp}} -> {:ok, Jason.decode!(resp)}
      {:ok, %Finch.Response{status: s}} -> {:error, "upstream_#{s}"}
      {:error, reason} -> {:error, inspect(reason)}
    end
  end
end
