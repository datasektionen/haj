defmodule HajWeb.MerchAdminView do
  use HajWeb, :view

  import HajWeb.LiveComponents.Table

  defp list_items(order) do
    Enum.map(order.merch_order_items, fn item -> "#{item.count} x #{item.merch_item.name}" end) |> Enum.join(", ")
  end
end
