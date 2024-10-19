defmodule Haj.Repo.Migrations.CreateEventRegistrations do
  use Ecto.Migration

  def change do
    create table(:event_registrations) do
      add :ticket_type_id, references(:ticket_types, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:event_registrations, [:ticket_type_id])
    create index(:event_registrations, [:user_id])
  end
end
