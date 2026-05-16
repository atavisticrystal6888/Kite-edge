defmodule KiteEdgeWeb.Plugs.RateLimiter do
  @moduledoc """
  Per-IP API rate limiter using Cachex.

  Allows a configurable number of requests per window (default: 60 req/min).
  Returns 429 Too Many Requests when exceeded.
  """
  import Plug.Conn

  @default_limit 60
  @default_window_ms 60_000

  def init(opts) do
    %{
      limit: Keyword.get(opts, :limit, @default_limit),
      window_ms: Keyword.get(opts, :window_ms, @default_window_ms)
    }
  end

  def call(conn, %{limit: limit, window_ms: window_ms}) do
    key = rate_limit_key(conn)

    case check_rate(key, limit, window_ms) do
      {:allow, count} ->
        conn
        |> put_resp_header("x-ratelimit-limit", Integer.to_string(limit))
        |> put_resp_header("x-ratelimit-remaining", Integer.to_string(max(limit - count, 0)))

      :deny ->
        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("x-ratelimit-limit", Integer.to_string(limit))
        |> put_resp_header("x-ratelimit-remaining", "0")
        |> put_resp_header("retry-after", Integer.to_string(div(window_ms, 1000)))
        |> send_resp(429, Jason.encode!(%{error: "rate_limit_exceeded", retry_after_seconds: div(window_ms, 1000)}))
        |> halt()
    end
  end

  defp rate_limit_key(conn) do
    ip =
      conn.remote_ip
      |> :inet.ntoa()
      |> to_string()

    "rate:#{ip}:#{System.system_time(:second) |> div(60)}"
  end

  defp check_rate(key, limit, window_ms) do
    ttl = div(window_ms, 1000)

    case Cachex.get(:kite_edge_cache, key) do
      {:ok, nil} ->
        Cachex.put(:kite_edge_cache, key, 1, ttl: :timer.seconds(ttl))
        {:allow, 1}

      {:ok, count} when count < limit ->
        Cachex.incr(:kite_edge_cache, key)
        {:allow, count + 1}

      {:ok, _count} ->
        :deny

      _ ->
        {:allow, 0}
    end
  end
end
