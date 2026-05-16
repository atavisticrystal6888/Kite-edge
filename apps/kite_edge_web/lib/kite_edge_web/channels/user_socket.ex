defmodule KiteEdgeWeb.UserSocket do
  use Phoenix.Socket

  channel "portfolio:*", KiteEdgeWeb.PortfolioChannel
  channel "ticks:*", KiteEdgeWeb.TicksChannel
  channel "alerts:*", KiteEdgeWeb.AlertsChannel
  channel "analytics:*", KiteEdgeWeb.AnalyticsChannel

  @impl true
  def connect(%{"session_id" => session_id}, socket, _connect_info)
      when is_binary(session_id) and byte_size(session_id) > 0 do
    case KiteEdge.Kite.SessionStore.fetch(session_id) do
      {:ok, payload} -> {:ok, assign(socket, :kite_session, payload)}
      _ -> :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.kite_session["user_id"]}"
end
