defmodule KiteEdgeWeb.WatchlistsController do
  @moduledoc "T163b: Watchlist CRUD controller."
  use KiteEdgeWeb, :controller

  alias KiteEdge.Watchlists

  def index(conn, _params) do
    user_id = conn.assigns.kite_session["user_id"]
    watchlists = Watchlists.list_for_user(user_id)
    json(conn, %{data: watchlists})
  end

  def create(conn, params) do
    user_id = conn.assigns.kite_session["user_id"]
    attrs = Map.put(params, "user_id", user_id)
    case Watchlists.create(attrs) do
      {:ok, wl} -> conn |> put_status(201) |> json(%{data: wl})
      {:error, cs} -> conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    case Watchlists.update(id, params) do
      {:ok, wl} -> json(conn, %{data: wl})
      {:error, cs} -> conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    case Watchlists.delete(id) do
      {:ok, _} -> send_resp(conn, 204, "")
      {:error, reason} -> conn |> put_status(422) |> json(%{error: reason})
    end
  end

  defp format_errors(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, _opts} -> msg end)
  end
  defp format_errors(other), do: %{detail: inspect(other)}
end
