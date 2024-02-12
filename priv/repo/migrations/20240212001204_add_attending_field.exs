defmodule Haj.Repo.Migrations.AddAttendingField do
  use Ecto.Migration

  def change do
    alter table(:event_registrations) do
      add :attending, :boolean, default: false
    end
  end
end
