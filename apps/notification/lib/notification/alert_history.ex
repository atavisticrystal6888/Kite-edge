defmodule Notification.AlertHistory do
  @moduledoc "T163: Alert-history persistence and unread state handling."
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "alert_history" do
    field :user_id, :string
    field :alert_type, :string
    field :headline, :string
    field :body, :string
    field :symbol, :string
    field :read, :boolean, default: false
    field :fired_at, :utc_datetime
    timestamps()
  end

  def changeset(alert, attrs) do
    alert
    |> cast(attrs, [:user_id, :alert_type, :headline, :body, :symbol, :read, :fired_at])
    |> validate_required([:user_id, :headline, :fired_at])
  end

  def record(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> KiteEdge.Repo.insert()
  end

  def unread_for_user(user_id) do
    from(a in __MODULE__,
      where: a.user_id == ^user_id and a.read == false,
      order_by: [desc: a.fired_at]
    )
    |> KiteEdge.Repo.all()
  end

  def mark_read(alert_id) do
    KiteEdge.Repo.get!(__MODULE__, alert_id)
    |> changeset(%{read: true})
    |> KiteEdge.Repo.update()
  end
end
