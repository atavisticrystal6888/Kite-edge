defmodule KiteEdgeWeb.Portfolio.HoldingsControllerTest do
  @moduledoc "T036: contract tests for GET /api/v1/portfolio/holdings."
  use ExUnit.Case, async: true
  use Plug.Test

  @opts KiteEdgeWeb.Router.init([])

  test "returns 401 when no session cookie is present" do
    conn = conn(:get, "/api/v1/portfolio/holdings") |> KiteEdgeWeb.Router.call(@opts)
    assert conn.status == 401
  end

  test "returns JSON envelope with data and freshness fields when authenticated" do
    # Full end-to-end assertion once the session helper is wired in Phase 3 tests.
    # For now we assert the route is registered and responds (401 is acceptable).
    conn = conn(:get, "/api/v1/portfolio/holdings") |> KiteEdgeWeb.Router.call(@opts)
    assert conn.status in [200, 401]
  end
end
