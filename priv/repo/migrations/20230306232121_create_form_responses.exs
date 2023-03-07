defmodule Haj.Repo.Migrations.CreateFormResponses do
  use Ecto.Migration

  def change do
    create table(:form_responses) do
      add(:user_id, references(:users, on_delete: :nothing))
      add(:form_id, references(:forms, on_delete: :nothing))

      timestamps()
    end

    create(index(:form_responses, [:user_id]))
    create(index(:form_responses, [:form_id]))
  end
end
