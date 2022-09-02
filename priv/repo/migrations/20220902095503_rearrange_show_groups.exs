defmodule Haj.Repo.Migrations.RearrangeShowGroups do
  use Ecto.Migration

  def change do
    alter table("group_memberships") do
      remove :show_id
      remove :group_id

      add :show_group_id, references(:show_groups, on_delete: :nothing)
    end
  end
end
