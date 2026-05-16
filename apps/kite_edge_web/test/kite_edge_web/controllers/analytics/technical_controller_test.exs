defmodule KiteEdgeWeb.Analytics.TechnicalControllerTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase4

  describe "POST /api/v1/analytics/technical/:symbol" do
    test "returns 401 without session", %{conn: conn} do
      conn = post(conn, "/api/v1/analytics/technical/RELIANCE", %{"exchange" => "NSE"})
      assert json_response(conn, 401)
    end
  end
end
