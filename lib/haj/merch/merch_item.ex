defmodule Haj.Merch.MerchItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merch_items" do
    field :name, :string
    field :price, :integer
    field :sizes, {:array, :string}
    field :purchase_deadline, :utc_datetime
    field :image, :string
    field :description, :string

    belongs_to :show, Haj.Spex.Show
    has_many :merch_order_items, Haj.Merch.MerchOrderItem

    field :temp_id, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(merch_item, attrs) do
    merch_item
    # So its persisted
    |> Map.put(:temp_id, merch_item.temp_id || attrs["temp_id"])
    |> cast(attrs, [:name, :price, :sizes, :show_id, :purchase_deadline, :image, :description])
    |> validate_required([:name, :price, :sizes])
    |> validate_length(:sizes, min: 1)
    |> validate_number(:price, greater_than_or_equal_to: 0)
  end
end
