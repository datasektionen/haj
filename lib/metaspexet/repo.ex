defmodule Metaspexet.Repo do
  use Ecto.Repo,
    otp_app: :metaspexet,
    adapter: Ecto.Adapters.Postgres
end
