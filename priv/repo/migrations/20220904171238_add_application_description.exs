defmodule Haj.Repo.Migrations.AddApplicationDescription do
  use Ecto.Migration

  def change do
    alter table(:show_groups) do
      add :application_description, :text
      add :application_open, :boolean, default: false
    end
  end
end
