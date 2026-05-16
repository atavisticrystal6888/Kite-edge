defmodule KiteEdgeWeb.HealthMetricsControllerTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase10

  describe "GET /health" do
    test "returns health status", %{conn: conn} do
      conn = get(conn, "/health")
      assert %{"status" => _} = json_response(conn, 200)
    end
  end
end
