defmodule KiteEdge.Settings.NotificationPreferences do
  @moduledoc "T163d: Per-user notification preferences (in-app, email, thresholds)."
  use Ecto.Schema
  import Ecto.Changeset

  schema "notification_preferences" do
    field :user_id, :string
    field :in_app_enabled, :boolean, default: true
    field :email_enabled, :boolean, default: false
    field :email_address, :string
    field :price_threshold_pct, :decimal, default: Decimal.new("5.0")
    field :daily_digest, :boolean, default: false
    timestamps()
  end

  def changeset(prefs, attrs) do
    prefs
    |> cast(attrs, [:user_id, :in_app_enabled, :email_enabled, :email_address, :price_threshold_pct, :daily_digest])
    |> validate_required([:user_id])
    |> unique_constraint(:user_id)
    |> validate_format(:email_address, ~r/@/, message: "must contain @")
  end
end
