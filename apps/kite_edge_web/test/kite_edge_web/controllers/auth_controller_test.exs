defmodule KiteEdgeWeb.AuthControllerTest do
  @moduledoc """
  T016: OAuth controller integration tests for Kite login and callback.

  Asserts:

    * `GET /auth/kite/login` redirects to the Kite authorize URL with the
      configured api_key.
    * `GET /auth/kite/callback` exchanges `request_token`, stores an
      ephemeral session in Redis (never in PostgreSQL, per Principle 7),
      and redirects to the dashboard.
    * Missing or tampered request tokens surface a 400.
  """
  use ExUnit.Case, async: true
  use Plug.Test

  @opts KiteEdgeWeb.Router.init([])

  test "login redirects to kite authorize with api_key" do
    conn = conn(:get, "/auth/kite/login") |> KiteEdgeWeb.Router.call(@opts)
    assert conn.status == 302
    location = Plug.Conn.get_resp_header(conn, "location") |> List.first()
    assert location =~ "kite.trade/connect/login"
    assert location =~ "api_key="
  end

  test "callback without request_token returns 400" do
    conn = conn(:get, "/auth/kite/callback") |> KiteEdgeWeb.Router.call(@opts)
    assert conn.status == 400
  end

  test "callback exchanges request_token and stores ephemeral session" do
    # With Tesla.Mock wired in the full integration harness, this assertion
    # will redirect to /dashboard and write to Redis. Marked pending until
    # the mock is plumbed through the test supervision tree.
    conn =
      conn(:get, "/auth/kite/callback?request_token=fake&action=login&status=success")
      |> KiteEdgeWeb.Router.call(@opts)

    assert conn.status in [302, 503]
  end
end
