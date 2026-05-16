defmodule KiteEdgeWeb.InstrumentsControllerTest do
  use KiteEdgeWeb.ConnCase, async: true

  @moduletag :phase4

  describe "GET /api/v1/instruments/search" do
    test "returns 401 without session", %{conn: conn} do
      conn = get(conn, "/api/v1/instruments/search", %{"query" => "RELIANCE"})
      assert json_response(conn, 401)
    end
  end

  describe "GET /api/v1/instruments/:symbol/quote" do
    test "returns 401 without session", %{conn: conn} do
      conn = get(conn, "/api/v1/instruments/RELIANCE/quote")
      assert json_response(conn, 401)
    end
  end

  describe "GET /api/v1/instruments/:symbol/ohlcv" do
    test "returns 401 without session", %{conn: conn} do
      conn = get(conn, "/api/v1/instruments/RELIANCE/ohlcv")
      assert json_response(conn, 401)
    end
  end
end
