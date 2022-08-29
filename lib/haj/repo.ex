defmodule Haj.Repo do
  use Ecto.Repo,
    otp_app: :haj,
    adapter: Ecto.Adapters.Postgres
end
