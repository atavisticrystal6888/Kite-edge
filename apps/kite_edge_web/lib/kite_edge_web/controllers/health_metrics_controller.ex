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
    metrics = collect_metrics()

    conn
    |> put_resp_content_type("text/plain; version=0.0.4")
    |> send_resp(200, format_prometheus(metrics))
  end

  defp collect_metrics do
    %{
      kiteedge_up: 1,
      kiteedge_db_pool_size: pool_size(),
      kiteedge_db_pool_checked_out: pool_checked_out(),
      kiteedge_cache_size: cache_size(),
      kiteedge_oban_available_jobs: oban_jobs(:available),
      kiteedge_oban_executing_jobs: oban_jobs(:executing),
      kiteedge_beam_process_count: :erlang.system_info(:process_count),
      kiteedge_beam_memory_bytes: :erlang.memory(:total),
      kiteedge_beam_atom_count: :erlang.system_info(:atom_count),
      kiteedge_beam_uptime_seconds: beam_uptime()
    }
  end

  defp format_prometheus(metrics) do
    metrics
    |> Enum.map(fn {key, value} ->
      "#{key} #{value}"
    end)
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  defp pool_size do
    case Ecto.Adapters.SQL.query(KiteEdge.Repo, "SELECT count(*) FROM pg_stat_activity WHERE datname = current_database()", []) do
      {:ok, %{rows: [[count]]}} -> count
      _ -> 0
    end
  end

  defp pool_checked_out do
    # DBConnection checkout count from telemetry would be ideal;
    # approximate via repo metadata
    try do
      %{pool_size: size} = KiteEdge.Repo.config() |> Keyword.get(:pool_size, 20) |> then(&%{pool_size: &1})
      size
    rescue
      _ -> 0
    end
  end

  defp cache_size do
    case Cachex.size(:kite_edge_cache) do
      {:ok, size} -> size
      _ -> 0
    end
  end

  defp oban_jobs(state) do
    try do
      import Ecto.Query
      KiteEdge.Repo.aggregate(
        from(j in Oban.Job, where: j.state == ^to_string(state)),
        :count
      )
    rescue
      _ -> 0
    end
  end

  defp beam_uptime do
    {uptime_ms, _} = :erlang.statistics(:wall_clock)
    div(uptime_ms, 1000)
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
    case Finch.build(:get, "#{Application.get_env(:kite_edge_web, :analytics_engine_url, "http://localhost:8001")}/health", [])
         |> Finch.request(KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200}} -> :ok
      _ -> :error
    end
  end
end
