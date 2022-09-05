defmodule Haj.Repo.Migrations.AddApplicationShowAssoc do
  use Ecto.Migration

  def change do
    alter table(:applications) do
      add :show_id, references(:shows, on_delete: :nothing)
    end

    create index(:applications, [:show_id])

  end
end
