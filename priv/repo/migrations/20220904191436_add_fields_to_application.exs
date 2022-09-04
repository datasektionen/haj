defmodule Haj.Repo.Migrations.AddFieldsToApplication do
  use Ecto.Migration

  def change do
    alter table(:applications) do
      add :special_text, :text
      add :other, :text
    end
  end
end
