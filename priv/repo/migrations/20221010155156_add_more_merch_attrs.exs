defmodule Haj.Repo.Migrations.AddMoreMerchAttrs do
  use Ecto.Migration

  def change do
    alter table(:merch_items) do
      add :purchase_deadline, :utc_datetime
      add :image, :string
      add :description, :text
    end
  end
end
