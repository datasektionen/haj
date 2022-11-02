defmodule Haj.Repo.Migrations.CreateMerchOrderItems do
  use Ecto.Migration

  def change do
    create table(:merch_order_items) do
      add :size, :string
      add :count, :integer
      add :merch_order_id, references(:merch_orders, on_delete: :nothing)
      add :merch_item_id, references(:merch_items, on_delete: :nothing)

      timestamps()
    end

    create index(:merch_order_items, [:merch_order_id])
    create index(:merch_order_items, [:merch_item_id])
  end
end
