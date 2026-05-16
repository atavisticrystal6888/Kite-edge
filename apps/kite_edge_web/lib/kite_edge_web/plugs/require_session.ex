defmodule KiteEdgeWeb.Plugs.RequireSession do
  @moduledoc "Resolves the kiteedge_session cookie to a Redis session payload or 401."
  import Plug.Conn

  alias KiteEdge.Kite.SessionStore

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_cookies(conn)

    case Map.get(conn.req_cookies, "kiteedge_session") do
      nil ->
        halt_unauthorized(conn)

      sid ->
        case SessionStore.fetch(sid) do
          {:ok, session} -> assign(conn, :kite_session, session)
          _ -> halt_unauthorized(conn)
        end
    end
  end

  defp halt_unauthorized(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Jason.encode!(%{error: "unauthenticated"}))
    |> halt()
  end
end
