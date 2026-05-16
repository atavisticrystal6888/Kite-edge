defmodule KiteEdgeWeb.HealthMetricsController do
  @moduledoc "T195: Prometheus health and metrics exposure."
  use KiteEdgeWeb, :controller

  def health(conn, _params) do
    checks = %{
      database: check_db(),
      redis: check_redis(),
      analytics_engine: check_analytics()
    }

    status = if Enum.all?(Map.values(checks), &(&1 == :ok)), do: 200, else: 503
    conn |> put_status(status) |> json(%{status: if(status == 200, do: "healthy", else: "degraded"), checks: checks})
  end

  def metrics(conn, _params) do
    # Placeholder: In production, expose Prometheus metrics via :telemetry
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "# KiteEdge metrics\nkiteedge_up 1\n")
  end

  defp check_db do
    case Ecto.Adapters.SQL.query(KiteEdge.Repo, "SELECT 1", []) do
      {:ok, _} -> :ok
      _ -> :error
    end
  end

  defp check_redis do
    case KiteEdge.Kite.SessionStore.fetch("__health_check__") do
      :error -> :ok
      {:ok, _} -> :ok
      _ -> :error
    end
  end

  defp check_analytics do
    case Finch.build(:get, "#{Application.get_env(:kite_edge_web, :analytics_engine_url, "http://localhost:8000")}/health", [])
         |> Finch.request(KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200}} -> :ok
      _ -> :error
    end
  end
end
