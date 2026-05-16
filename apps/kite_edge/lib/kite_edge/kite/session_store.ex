defmodule KiteEdge.Kite.SessionStore do
  @moduledoc """
  Ephemeral Kite session storage.

  Constitution Principle 7 (MUST): access tokens are NEVER persisted in
  PostgreSQL. They live only in Redis with a TTL that matches Kite's
  trading-day expiry (~06:00 IST next day).

  The store is addressed by an opaque KiteEdge session id (not the Kite
  user id directly). The mapping from session id to Kite user id is also
  kept in Redis only.
  """
  use GenServer

  @ttl_seconds 18 * 60 * 60

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def put(session_id, payload) when is_binary(session_id) and is_map(payload) do
    GenServer.call(__MODULE__, {:put, session_id, payload})
  end

  def fetch(session_id) when is_binary(session_id) do
    GenServer.call(__MODULE__, {:fetch, session_id})
  end

  def delete(session_id) when is_binary(session_id) do
    GenServer.call(__MODULE__, {:delete, session_id})
  end

  @impl true
  def init(_opts) do
    url = Application.get_env(:kite_edge, :redis_url, System.get_env("REDIS_URL", "redis://localhost:6379/0"))
    {:ok, conn} = Redix.start_link(url, name: :kite_edge_redix_session)
    {:ok, %{conn: conn}}
  end

  @impl true
  def handle_call({:put, session_id, payload}, _from, %{conn: conn} = s) do
    json = Jason.encode!(payload)
    case Redix.command(conn, ["SET", key(session_id), json, "EX", Integer.to_string(@ttl_seconds)]) do
      {:ok, _} -> {:reply, :ok, s}
      {:error, _} = err -> {:reply, err, s}
    end
  end

  def handle_call({:fetch, session_id}, _from, %{conn: conn} = s) do
    case Redix.command(conn, ["GET", key(session_id)]) do
      {:ok, nil} -> {:reply, :error, s}
      {:ok, json} -> {:reply, {:ok, Jason.decode!(json)}, s}
      {:error, _} = err -> {:reply, err, s}
    end
  end

  def handle_call({:delete, session_id}, _from, %{conn: conn} = s) do
    case Redix.command(conn, ["DEL", key(session_id)]) do
      {:ok, _} -> {:reply, :ok, s}
      {:error, _} = err -> {:reply, err, s}
    end
  end

  defp key(session_id), do: "kiteedge:session:#{session_id}"
end
