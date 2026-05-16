defmodule KiteEdge.Release do
  @moduledoc """
  Release tasks for running migrations in production.

  Usage (inside Docker container or release binary):

      bin/kite_edge eval "KiteEdge.Release.migrate()"
      bin/kite_edge eval "KiteEdge.Release.rollback(KiteEdge.Repo, 20240101000000)"
  """

  @app :kite_edge

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
