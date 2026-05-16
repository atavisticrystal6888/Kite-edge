defmodule KiteEdge.Repo.Migrations.CreateSettingsAndWatchlists do
  @moduledoc """
  Phase 4 Remediation migration (T025a).

  Adds:
    * indicator_profiles (FR-023 persisted technical analysis settings)
    * notification_preferences (FR-071 email/in-app alert channel config)
    * watchlists + watchlist_items (FR-070 custom watchlist CRUD)
  """
  use Ecto.Migration

  def change do
    create table(:indicator_profiles) do
      add :profile_key, :string, size: 64, null: false
      add :parameters, :map, null: false, default: %{}
      add :is_default, :boolean, null: false, default: false
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:indicator_profiles, [:profile_key])

    create unique_index(:indicator_profiles, [:is_default],
             where: "is_default = true",
             name: :indicator_profiles_single_default_idx
           )

    create table(:notification_preferences) do
      add :channel, :string, size: 16, null: false
      add :enabled, :boolean, null: false, default: true
      add :email_address, :string, size: 255
      add :severity_floor, :string, size: 16, null: false
      add :quiet_hours, :map
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:notification_preferences, [:channel])

    create table(:watchlists) do
      add :name, :string, size: 128, null: false
      add :description, :text
      add :display_order, :integer, null: false, default: 0
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:watchlists, [:name])

    create table(:watchlist_items) do
      add :watchlist_id, references(:watchlists, on_delete: :delete_all), null: false
      add :instrument_id, references(:instrument_masters, on_delete: :restrict), null: false
      add :display_order, :integer, null: false, default: 0
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:watchlist_items, [:watchlist_id, :instrument_id])
    create index(:watchlist_items, [:watchlist_id, :display_order])
  end
end
