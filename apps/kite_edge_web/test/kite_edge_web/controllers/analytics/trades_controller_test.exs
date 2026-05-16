defmodule KiteEdgeWeb.Analytics.TradesControllerTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase7

  describe "GET /api/v1/analytics/trades/performance" do
    test "returns 401 without session", %{conn: conn} do
      conn = get(conn, "/api/v1/analytics/trades/performance")
      assert json_response(conn, 401)
    end
  end
end
