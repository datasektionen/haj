defmodule Haj.Repo.Migrations.AddGroupDescriptions do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add(:description, :text)
    end
  end
end
