defmodule KiteEdgeWeb.Analytics.ForecastControllerTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase6

  describe "POST /api/v1/analytics/forecast/:symbol" do
    test "returns 401 without session", %{conn: conn} do
      conn = post(conn, "/api/v1/analytics/forecast/RELIANCE", %{})
      assert json_response(conn, 401)
    end
  end
end
