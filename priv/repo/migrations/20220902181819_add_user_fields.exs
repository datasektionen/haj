defmodule Haj.Repo.Migrations.AddUserFields do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :google_account, :string
      add :phone, :string
      add :class, :string
      add :personal_number, :string
      add :role, :string
    end
  end
end
