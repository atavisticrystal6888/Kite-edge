defmodule KiteEdge.Watchlists do
  @moduledoc "T163a: Watchlist schemas and Ecto context."
  import Ecto.Query
  alias KiteEdge.Repo

  defmodule Watchlist do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, only: [:id, :user_id, :name, :symbols, :sort_order, :inserted_at, :updated_at]}

    schema "watchlists" do
      field :user_id, :string
      field :name, :string
      field :symbols, {:array, :string}, default: []
      field :sort_order, :integer, default: 0
      timestamps()
    end

    def changeset(wl, attrs) do
      wl
      |> cast(attrs, [:user_id, :name, :symbols, :sort_order])
      |> validate_required([:user_id, :name])
    end
  end

  def list_for_user(user_id) do
    from(w in Watchlist, where: w.user_id == ^user_id, order_by: w.sort_order)
    |> Repo.all()
  end

  def create(attrs) do
    %Watchlist{}
    |> Watchlist.changeset(attrs)
    |> Repo.insert()
  end

  def update(id, user_id, attrs) do
    case Repo.get_by(Watchlist, id: id, user_id: user_id) do
      nil -> {:error, :not_found}
      wl -> wl |> Watchlist.changeset(attrs) |> Repo.update()
    end
  end

  def delete(id, user_id) do
    case Repo.get_by(Watchlist, id: id, user_id: user_id) do
      nil -> {:error, :not_found}
      wl -> Repo.delete(wl)
    end
  end
end
