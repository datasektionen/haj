defmodule Haj.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :poll_id, references(:polls, on_delete: :delete_all)
      add :option_id, references(:options, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:votes, [:poll_id])
    create index(:votes, [:option_id])
    create index(:votes, [:user_id])
  end
end
