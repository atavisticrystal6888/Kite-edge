defmodule KiteEdge.Repo do
  use Ecto.Repo,
    otp_app: :kite_edge,
    adapter: Ecto.Adapters.Postgres
end
