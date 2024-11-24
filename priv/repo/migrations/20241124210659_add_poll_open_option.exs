defmodule Haj.Repo.Migrations.AddPollOpenOption do
  use Ecto.Migration

  def change do
    alter table(:polls) do
      add :open, :boolean, default: true
    end
  end
end
