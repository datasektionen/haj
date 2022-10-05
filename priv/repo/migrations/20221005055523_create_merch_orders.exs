defmodule Haj.Repo.Migrations.CreateMerchOrders do
  use Ecto.Migration

  def change do
    create table(:merch_orders) do
      add :paid, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:merch_orders, [:user_id])
  end
end
