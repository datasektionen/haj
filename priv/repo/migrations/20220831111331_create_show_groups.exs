defmodule Haj.Repo.Migrations.CreateShowGroups do
  use Ecto.Migration

  def change do
    create table(:show_groups) do
      add :show_id, references(:shows, on_delete: :nothing)
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps()
    end

    create index(:show_groups, [:show_id])
    create index(:show_groups, [:group_id])
  end
end
