defmodule Haj.Merch.MerchItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merch_items" do
    field :name, :string
    field :price, :integer
    field :sizes, {:array, :string}

    belongs_to :show, Haj.Spex.Show
    has_many :merch_order_items, Haj.Merch.MerchOrderItem

    timestamps()
  end

  @doc false
  def changeset(merch_item, attrs) do
    merch_item
    |> cast(attrs, [:name, :price, :sizes, :show_id])
    |> validate_required([:name, :price, :sizes])
    |> validate_length(:sizes, min: 1)
    |> validate_number(:price, greater_than_or_equal_to: 0)
  end
end
