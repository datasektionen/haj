defmodule Haj.Repo.Migrations.AddApplicationStatus do
  use Ecto.Migration

  def change do
    alter table(:applications) do
      add(:status, :string, default: "pending")
    end
  end
end
