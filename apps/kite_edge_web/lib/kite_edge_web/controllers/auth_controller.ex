defmodule KiteEdgeWeb.AuthController do
  @moduledoc """
  Kite Connect OAuth handshake.

  Flow:
    1. `GET /auth/kite/login` -> redirect to `https://kite.trade/connect/login?v=3&api_key=<k>`.
    2. User authorizes. Kite redirects back to `/auth/kite/callback?request_token=...`.
    3. Server POSTs to `/session/token` with checksum = SHA256(api_key + request_token + api_secret).
    4. The returned `access_token` is stored ONLY in `KiteEdge.Kite.SessionStore` (Redis).
       It is never written to PostgreSQL (Constitution Principle 7).
  """
  use KiteEdgeWeb, :controller

  alias KiteEdge.Kite.{Client, SessionStore}
  require Logger

  def login(conn, _params) do
    api_key = Application.get_env(:kite_edge, :kite_api_key, System.get_env("KITE_API_KEY", ""))

    url =
      "https://kite.trade/connect/login?" <>
        URI.encode_query(%{"v" => "3", "api_key" => api_key})

    redirect(conn, external: url)
  end

  def callback(conn, %{"request_token" => request_token}) do
    api_key = Application.get_env(:kite_edge, :kite_api_key, System.get_env("KITE_API_KEY", ""))
    api_secret = Application.get_env(:kite_edge, :kite_api_secret, System.get_env("KITE_API_SECRET", ""))

    checksum =
      :crypto.hash(:sha256, api_key <> request_token <> api_secret)
      |> Base.encode16(case: :lower)

    body = %{
      "api_key" => api_key,
      "request_token" => request_token,
      "checksum" => checksum
    }

    case exchange_token(body) do
      {:ok, %{"data" => %{"access_token" => token, "user_id" => user_id} = data}} ->
        session_id = :crypto.strong_rand_bytes(24) |> Base.url_encode64(padding: false)

        :ok =
          SessionStore.put(session_id, %{
            "access_token" => token,
            "user_id" => user_id,
            "user_name" => data["user_name"],
            "email" => data["email"]
          })

        conn
        |> put_resp_cookie("kiteedge_session", session_id,
          http_only: true,
          same_site: "Lax",
          secure: conn.scheme == :https,
          max_age: 18 * 60 * 60
        )
        |> redirect(to: "/dashboard")

      {:error, reason} ->
        Logger.error("token exchange failed: #{inspect(reason)}")
        send_resp(conn, 503, "kite session exchange unavailable")
    end
  end

  def callback(conn, _params) do
    send_resp(conn, 400, "missing request_token")
  end

  def logout(conn, _params) do
    case conn.cookies["kiteedge_session"] do
      nil -> :ok
      sid -> SessionStore.delete(sid)
    end

    conn
    |> delete_resp_cookie("kiteedge_session")
    |> send_resp(204, "")
  end

  defp exchange_token(body) do
    case Tesla.post(Client, "/session/token", body) do
      {:ok, %Tesla.Env{status: 200, body: payload}} -> {:ok, payload}
      {:ok, %Tesla.Env{status: status, body: payload}} -> {:error, {status, payload}}
      {:error, _} = err -> err
    end
  end
end
