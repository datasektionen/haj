defmodule Haj.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :description, :text
      add :image, :text
      add :ticket_limit, :integer
      add :event_date, :utc_datetime
      add :purchase_deadline, :utc_datetime

      timestamps()
    end
  end
end
