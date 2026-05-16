defmodule KiteEdge.DataCase do
  @moduledoc """
  Test case for tests that need the database.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      alias KiteEdge.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import KiteEdge.DataCase
    end
  end

  setup tags do
    KiteEdge.DataCase.setup_sandbox(tags)
    :ok
  end

  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(KiteEdge.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end
end
