defmodule Haj.Repo.Migrations.CreateShows do
  use Ecto.Migration

  def change do
    create table(:shows) do
      add :title, :string
      add :or_title, :string
      add :year, :date
      add :description, :string

      timestamps()
    end
  end
end
