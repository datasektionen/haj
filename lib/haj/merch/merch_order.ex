defmodule Haj.Merch.MerchOrder do
  use Ecto.Schema
  import Ecto.Changeset

  schema "merch_orders" do
    field :paid, :boolean, default: false

    belongs_to :user, Haj.Accounts.User
    belongs_to :show, Haj.Spex.Show
    has_many :merch_order_items, Haj.Merch.MerchOrderItem

    timestamps()
  end

  @doc false
  def changeset(merch_order, attrs) do
    merch_order
    |> cast(attrs, [:paid, :user_id, :show_id])
    |> validate_required([:paid])
  end
end
