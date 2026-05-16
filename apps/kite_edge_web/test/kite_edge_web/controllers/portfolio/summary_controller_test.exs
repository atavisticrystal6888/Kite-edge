defmodule KiteEdgeWeb.Portfolio.SummaryControllerTest do
  @moduledoc "T040: contract tests for GET /api/v1/portfolio/summary."
  use ExUnit.Case, async: true
  use Plug.Test

  @opts KiteEdgeWeb.Router.init([])

  test "route is registered" do
    conn = conn(:get, "/api/v1/portfolio/summary") |> KiteEdgeWeb.Router.call(@opts)
    assert conn.status in [200, 401]
  end
end
