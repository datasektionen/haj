defmodule Haj.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options) do
      add :name, :string
      add :description, :string
      add :url, :string
      add :poll_id, references(:polls, on_delete: :delete_all)
      add :creator_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:options, [:poll_id])
    create index(:options, [:creator_id])
  end
end
