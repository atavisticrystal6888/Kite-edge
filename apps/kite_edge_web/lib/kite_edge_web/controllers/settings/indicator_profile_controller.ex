defmodule KiteEdgeWeb.Settings.IndicatorProfileController do
  @moduledoc "T073b: Indicator profile controller and routes."
  use KiteEdgeWeb, :controller

  alias KiteEdge.Settings.IndicatorProfile
  alias KiteEdge.Repo
  import Ecto.Query

  def show(conn, _params) do
    user_id = conn.assigns.kite_session["user_id"]
    profile = Repo.one(from p in IndicatorProfile, where: p.user_id == ^user_id, limit: 1)
    case profile do
      nil -> json(conn, %{data: %{name: "default", parameters: %{}}})
      p -> json(conn, %{data: %{name: p.name, parameters: p.parameters}})
    end
  end

  def update(conn, params) do
    user_id = conn.assigns.kite_session["user_id"]
    profile = Repo.one(from p in IndicatorProfile, where: p.user_id == ^user_id, limit: 1)

    result =
      case profile do
        nil -> %IndicatorProfile{} |> IndicatorProfile.changeset(Map.put(params, "user_id", user_id)) |> Repo.insert()
        p -> p |> IndicatorProfile.changeset(params) |> Repo.update()
      end

    case result do
      {:ok, p} -> json(conn, %{data: %{name: p.name, parameters: p.parameters}})
      {:error, cs} -> conn |> put_status(422) |> json(%{errors: Ecto.Changeset.traverse_errors(cs, fn {m, _} -> m end)})
    end
  end

  def reset(conn, _params) do
    user_id = conn.assigns.kite_session["user_id"]
    from(p in IndicatorProfile, where: p.user_id == ^user_id) |> Repo.delete_all()
    json(conn, %{data: %{name: "default", parameters: %{}}})
  end
end
