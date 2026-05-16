defmodule KiteEdge.Settings.IndicatorProfile do
  @moduledoc "T073: Persisted indicator parameter profiles."
  use Ecto.Schema
  import Ecto.Changeset

  schema "indicator_profiles" do
    field :user_id, :string
    field :name, :string, default: "default"
    field :parameters, :map, default: %{}
    timestamps()
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:user_id, :name, :parameters])
    |> validate_required([:user_id, :name])
    |> unique_constraint([:user_id, :name])
  end
end
