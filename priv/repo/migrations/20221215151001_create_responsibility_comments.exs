defmodule Haj.Repo.Migrations.CreateResponsibilityComments do
  use Ecto.Migration

  def change do
    create table(:responsibility_comments) do
      add :text, :text
      add :show_id, references(:shows, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :responsibility_id, references(:respnsibilities, on_delete: :nothing)

      timestamps()
    end

    create index(:responsibility_comments, [:show_id])
    create index(:responsibility_comments, [:user_id])
    create index(:responsibility_comments, [:responsibility_id])
  end
end
