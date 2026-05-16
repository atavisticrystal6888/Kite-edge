defmodule KiteEdgeWeb.Plugs.VerifyOrigin do
  @moduledoc """
  CSRF-like protection for JSON APIs.

  Verifies that mutating requests (POST, PUT, PATCH, DELETE) include either:
  - An `x-requested-with` header (XMLHttpRequest / fetch with custom header), or
  - An `origin` header matching the allowed CORS origins.

  This prevents cross-site request forgery without requiring form tokens,
  which is the standard approach for cookie-authenticated JSON APIs.
  """
  import Plug.Conn

  @mutating_methods ~w(POST PUT PATCH DELETE)

  def init(opts), do: opts

  def call(%{method: method} = conn, _opts) when method in @mutating_methods do
    cond do
      has_custom_header?(conn) ->
        conn

      origin_allowed?(conn) ->
        conn

      true ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{error: "origin_verification_failed"}))
        |> halt()
    end
  end

  def call(conn, _opts), do: conn

  defp has_custom_header?(conn) do
    case get_req_header(conn, "x-requested-with") do
      [_value | _] -> true
      _ -> false
    end
  end

  defp origin_allowed?(conn) do
    allowed = KiteEdgeWeb.Endpoint.cors_origins()

    case get_req_header(conn, "origin") do
      [origin | _] -> origin in allowed
      _ -> false
    end
  end
end
