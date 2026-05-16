defmodule KiteEdgeWeb.Reports.BIEndpointsTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase9

  describe "GET /api/v1/reports/odata" do
    test "returns 401 without session", %{conn: conn} do
      conn = get(conn, "/api/v1/reports/odata")
      assert json_response(conn, 401)
    end
  end

  describe "GET /api/v1/reports/odata/$metadata" do
    test "returns 401 without session", %{conn: conn} do
      conn = get(conn, "/api/v1/reports/odata/$metadata")
      assert json_response(conn, 401) || response(conn, 401)
    end
  end

  describe "POST /api/v1/reports/powerbi/push" do
    test "returns 401 without session", %{conn: conn} do
      conn = post(conn, "/api/v1/reports/powerbi/push")
      assert json_response(conn, 401)
    end
  end
end
