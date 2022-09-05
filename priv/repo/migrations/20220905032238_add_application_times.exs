defmodule Haj.Repo.Migrations.AddApplicationTimes do
  use Ecto.Migration

  def change do
    alter table(:shows) do
      add :application_opens, :utc_datetime
      add :application_closes, :utc_datetime
    end
  end
end
