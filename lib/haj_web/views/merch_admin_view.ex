defmodule HajWeb.MerchAdminHTML do
  use HajWeb, :view

  embed_templates("../templates/merch_admin/*")

  defp list_items(order) do
    Enum.map(order.merch_order_items, fn item -> "#{item.count} x #{item.merch_item.name}" end)
    |> Enum.join(", ")
  end
end
