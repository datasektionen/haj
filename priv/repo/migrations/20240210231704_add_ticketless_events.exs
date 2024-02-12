defmodule Haj.Repo.Migrations.AddTicketlessEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :has_tickets, :boolean, default: true
    end

    alter table(:event_registrations) do
      add :event_id, references(:events, on_delete: :delete_all)
    end

    create index(:event_registrations, [:event_id])
  end
end
