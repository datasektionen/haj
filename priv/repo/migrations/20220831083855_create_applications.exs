defmodule Haj.Repo.Migrations.CreateApplications do
  use Ecto.Migration

  def change do
    create table(:applications) do
      add :user_id, references(:users, on_delete: :nothing)
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps()
    end

    create index(:applications, [:user_id])
    create index(:applications, [:group_id])
  end
end
