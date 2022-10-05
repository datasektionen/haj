defmodule Haj.Repo.Migrations.AddMerchOrderShowAssoc do
  use Ecto.Migration

  def change do
    alter table(:merch_orders) do
      add :show_id, references(:shows, on_delete: :nothing)
    end

    create index(:merch_orders, [:show_id])
  end
end
