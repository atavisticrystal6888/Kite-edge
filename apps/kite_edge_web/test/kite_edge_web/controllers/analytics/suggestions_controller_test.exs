defmodule KiteEdgeWeb.Analytics.SuggestionsControllerTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase8

  describe "GET /api/v1/analytics/signals" do
    test "returns 401 without session", %{conn: conn} do
      conn = get(conn, "/api/v1/analytics/signals")
      assert json_response(conn, 401)
    end
  end
end
