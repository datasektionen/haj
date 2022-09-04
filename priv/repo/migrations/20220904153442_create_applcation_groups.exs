defmodule Haj.Repo.Migrations.CreateApplcationGroups do
  use Ecto.Migration

  def change do
    create table(:application_show_groups) do
      add :application_id, references(:applications, on_delete: :nothing)
      add :show_group_id, references(:show_groups, on_delete: :nothing)

      timestamps()
    end

    create index(:application_show_groups, [:application_id])
    create index(:application_show_groups, [:show_group_id])

    alter table(:applications) do
      remove :group_id, :integer
    end
  end
end
