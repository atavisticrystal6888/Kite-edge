defmodule KiteEdge.Watchlists do
  @moduledoc "T163a: Watchlist schemas and Ecto context."
  import Ecto.Query
  alias KiteEdge.Repo

  defmodule Watchlist do
    use Ecto.Schema
    import Ecto.Changeset

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

  def update(id, attrs) do
    Repo.get!(Watchlist, id)
    |> Watchlist.changeset(attrs)
    |> Repo.update()
  end

  def delete(id) do
    Repo.get!(Watchlist, id)
    |> Repo.delete()
  end
end
