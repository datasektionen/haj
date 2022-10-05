defmodule Haj.Repo.Migrations.CreateMerchItems do
  use Ecto.Migration

  def change do
    create table(:merch_items) do
      add :name, :string
      add :price, :integer
      add :sizes, {:array, :string}
      add :show_id, references(:shows, on_delete: :nothing)

      timestamps()
    end

    create index(:merch_items, [:show_id])
  end
end
