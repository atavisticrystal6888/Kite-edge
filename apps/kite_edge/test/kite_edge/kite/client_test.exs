defmodule KiteEdge.Kite.ClientTest do
  @moduledoc """
  T017: Kite client tests for request pacing, retry, and error mapping.

  These tests drive the HTTP client behind a Tesla.Mock adapter so we never
  hit the real Kite API. They assert:

    * Rate limiter blocks the 4th call issued within 1 second (3 req/sec cap).
    * 5xx responses are retried with exponential backoff up to the configured
      limit, then surfaced as `{:error, :upstream_unavailable}`.
    * Kite error envelopes are mapped to `{:error, {:kite, reason}}`.
  """
  use ExUnit.Case, async: false

  alias KiteEdge.Kite.Client

  setup do
    Tesla.Mock.mock_global(fn
      %{method: :get, url: "https://api.kite.trade/portfolio/holdings"} ->
        %Tesla.Env{status: 200, body: %{"status" => "success", "data" => []}}

      %{method: :get, url: "https://api.kite.trade/always-500"} ->
        %Tesla.Env{status: 500, body: %{"status" => "error", "message" => "boom"}}

      %{method: :get, url: "https://api.kite.trade/token-expired"} ->
        %Tesla.Env{
          status: 403,
          body: %{"status" => "error", "error_type" => "TokenException", "message" => "expired"}
        }
    end)

    :ok
  end

  test "happy path returns decoded payload" do
    assert {:ok, %{"data" => []}} = Client.get("/portfolio/holdings", access_token: "t0k3n")
  end

  test "token exception is mapped to a typed error" do
    assert {:error, {:kite, :token_expired}} = Client.get("/token-expired", access_token: "t0k3n")
  end

  test "repeated 5xx surfaces :upstream_unavailable after retries" do
    assert {:error, :upstream_unavailable} = Client.get("/always-500", access_token: "t0k3n")
  end

  test "rate limiter enforces 3 req/sec" do
    # The 4th call in a 1-second window must wait; we assert total elapsed >= 1000ms.
    start = System.monotonic_time(:millisecond)

    for _ <- 1..4, do: Client.get("/portfolio/holdings", access_token: "t0k3n")

    elapsed = System.monotonic_time(:millisecond) - start
    assert elapsed >= 1_000, "expected rate limiter to delay the 4th call (got #{elapsed}ms)"
  end
end
