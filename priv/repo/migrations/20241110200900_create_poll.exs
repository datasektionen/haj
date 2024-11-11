defmodule Haj.Repo.Migrations.CreatePoll do
  use Ecto.Migration

  def change do
    create table(:polls) do
      add :title, :string
      add :description, :string
      add :display_votes, :boolean, default: false, null: false
      add :allow_user_options, :boolean, default: false, null: false

      timestamps()
    end
  end
end
