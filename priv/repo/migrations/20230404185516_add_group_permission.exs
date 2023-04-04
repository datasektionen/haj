defmodule Haj.Repo.Migrations.AddGroupPermission do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add(:permission_group, :string)
    end
  end
end
