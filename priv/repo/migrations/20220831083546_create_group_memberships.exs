defmodule Haj.Repo.Migrations.CreateGroupMemberships do
  use Ecto.Migration

  def change do
    create table(:group_memberships) do
      add :role, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :show_id, references(:shows, on_delete: :nothing)
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps()
    end

    create index(:group_memberships, [:user_id])
    create index(:group_memberships, [:show_id])
    create index(:group_memberships, [:group_id])
  end
end
