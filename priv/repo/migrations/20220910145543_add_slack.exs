defmodule Haj.Repo.Migrations.AddSlack do
  use Ecto.Migration

  def change do
    alter table(:shows) do
      add :slack_webhook_url, :string
    end
  end
end
