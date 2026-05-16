defmodule KiteEdgeWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :kite_edge_web

  @doc "Returns allowed CORS origins from config or env var."
  def cors_origins do
    Application.get_env(:kite_edge_web, :cors_origins, ["http://localhost:5173"])
  end

  socket "/socket", KiteEdgeWeb.UserSocket,
    websocket: true,
    longpoll: false

  plug CORSPlug,
    origin: &KiteEdgeWeb.Endpoint.cors_origins/0,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    headers: ["authorization", "content-type", "x-requested-with"],
    max_age: 86_400

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json], pass: ["*/*"], json_decoder: Jason
  plug Plug.MethodOverride
  plug Plug.Head
  plug KiteEdgeWeb.Router
end
