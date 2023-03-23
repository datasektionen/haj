defmodule Haj.Repo.Migrations.CreateResponsibilities do
  use Ecto.Migration

  def change do
    create table(:responsibilities) do
      add :name, :string
      add :description, :text

      timestamps()
    end
  end
end
