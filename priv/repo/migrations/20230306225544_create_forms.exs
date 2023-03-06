defmodule Haj.Repo.Migrations.CreateForms do
  use Ecto.Migration

  def change do
    create table(:forms) do
      add(:name, :string)
      add(:description, :string)

      timestamps()
    end
  end
end
