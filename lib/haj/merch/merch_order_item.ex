defmodule Haj.Merch.MerchOrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merch_order_items" do
    field :count, :integer
    field :size, :string

    belongs_to :merch_order, Haj.Merch.MerchOrder
    belongs_to :merch_item, Haj.Merch.MerchItem

    timestamps()
  end

  @doc false
  def changeset(merch_order_item, attrs) do
    merch_order_item
    |> cast(attrs, [:size, :count, :merch_order_id, :merch_item_id])
    |> validate_required([:size, :count, :merch_order_id, :merch_item_id])
    |> validate_number(:count, greater_than: 0)
  end
end
