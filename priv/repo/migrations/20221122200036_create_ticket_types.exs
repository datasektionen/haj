defmodule Haj.Repo.Migrations.CreateTicketTypes do
  use Ecto.Migration

  def change do
    create table(:ticket_types) do
      add :price, :integer
      add :name, :string
      add :description, :text
      add :event_id, references(:events, on_delete: :delete_all)

      timestamps()
    end

    create index(:ticket_types, [:event_id])
  end
end
