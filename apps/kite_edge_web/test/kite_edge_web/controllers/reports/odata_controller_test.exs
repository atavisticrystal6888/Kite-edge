defmodule KiteEdgeWeb.Reports.OdataControllerTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase9

  describe "GET /api/v1/reports/odata/$metadata" do
    test "returns XML metadata", %{conn: conn} do
      conn = get(conn, "/api/v1/reports/odata/$metadata")
      assert response_content_type(conn, :xml) || conn.status == 200
    end
  end
end
