defmodule KiteEdgeWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :kite_edge_web

  socket "/socket", KiteEdgeWeb.UserSocket,
    websocket: true,
    longpoll: false

  plug CORSPlug, origin: ["http://localhost:5173"]
  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json], pass: ["*/*"], json_decoder: Jason
  plug Plug.MethodOverride
  plug Plug.Head
  plug KiteEdgeWeb.Router
end
