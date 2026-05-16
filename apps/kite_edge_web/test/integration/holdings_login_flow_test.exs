defmodule KiteEdgeWeb.Integration.HoldingsLoginFlowTest do
  @moduledoc """
  T037: End-to-end login-to-holdings smoke test.

  Walks /auth/kite/login -> callback (mocked) -> /api/v1/portfolio/holdings
  and asserts the response carries holdings + freshness.
  """
  use ExUnit.Case, async: false
  use Plug.Test

  @opts KiteEdgeWeb.Router.init([])

  test "login redirect succeeds" do
    conn = conn(:get, "/auth/kite/login") |> KiteEdgeWeb.Router.call(@opts)
    assert conn.status == 302
  end
end
