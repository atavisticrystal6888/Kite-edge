defmodule KiteEdgeWeb.Analytics.RiskControllerTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase5

  describe "POST /api/v1/analytics/risk/portfolio" do
    test "returns 401 without session", %{conn: conn} do
      conn = post(conn, "/api/v1/analytics/risk/portfolio", %{})
      assert json_response(conn, 401)
    end
  end
end
