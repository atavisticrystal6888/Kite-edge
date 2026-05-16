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
    user_id = conn.assigns.kite_session["user_id"]
    case Watchlists.update(id, user_id, params) do
      {:ok, wl} -> json(conn, %{data: wl})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not_found"})
      {:error, cs} -> conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    user_id = conn.assigns.kite_session["user_id"]
    case Watchlists.delete(id, user_id) do
      {:ok, _} -> send_resp(conn, 204, "")
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not_found"})
      {:error, reason} -> conn |> put_status(422) |> json(%{error: reason})
    end
  end

  defp format_errors(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, _opts} -> msg end)
  end
  defp format_errors(other), do: %{detail: inspect(other)}
end
