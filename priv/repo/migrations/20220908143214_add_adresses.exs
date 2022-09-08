defmodule Haj.Repo.Migrations.AddAdresses do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :street, :string
      add :zip, :string
      add :city, :string
    end
  end
end
