defmodule Haj.Repo.Migrations.AddEventForms do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :form_id, references(:forms, on_delete: :nilify_all)
    end

    alter table(:event_registrations) do
      add :response_id, references(:form_responses, on_delete: :nilify_all)
    end

    create index(:event_registrations, [:response_id])
    create index(:events, [:form_id])
  end
end
