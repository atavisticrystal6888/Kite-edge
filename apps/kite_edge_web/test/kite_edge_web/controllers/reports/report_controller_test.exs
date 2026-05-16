defmodule KiteEdgeWeb.Reports.ReportControllerTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase9

  describe "POST /api/v1/reports/tearsheet" do
    test "returns 401 without session", %{conn: conn} do
      conn = post(conn, "/api/v1/reports/tearsheet", %{})
      assert json_response(conn, 401)
    end
  end

  describe "POST /api/v1/reports/export" do
    test "returns 401 without session", %{conn: conn} do
      conn = post(conn, "/api/v1/reports/export", %{})
      assert json_response(conn, 401)
    end
  end
end
