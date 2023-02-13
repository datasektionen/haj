defmodule Haj.Repo.Migrations.CreateResponsibilityUsers do
  use Ecto.Migration

  def change do
    create table(:responsibility_users) do
      add :show_id, references(:shows, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :responsibility_id, references(:responsibilities, on_delete: :nothing)

      timestamps()
    end

    create index(:responsibility_users, [:show_id])
    create index(:responsibility_users, [:user_id])
    create index(:responsibility_users, [:responsibility_id])
  end
end
