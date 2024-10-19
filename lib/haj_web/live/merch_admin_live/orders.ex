defmodule HajWeb.MerchAdminLive.Orders do
  use HajWeb, :live_view

  alias Haj.Spex

  on_mount {HajWeb.UserAuth, {:authorize, :merch_list_orders}}

  @impl true
  def mount(_params, _session, socket) do
    show = Spex.current_spex()

    show_options =
      Spex.list_shows()
      |> Enum.map(fn %{id: id, year: year, title: title} ->
        [key: "#{year.year}: #{title}", value: id]
      end)

    {:ok,
     socket
     |> assign(
       show: show,
       show_options: show_options
     )
     |> load_merch(show)}
  end

  @impl true
  def handle_event("select_show", %{"show" => show_id}, socket) do
    show = Spex.get_show!(show_id)

    {:noreply, assign(socket, show: show) |> load_merch(show)}
  end

  defp load_merch(socket, show) do
    show_id = show.id

    orders =
      Haj.Merch.list_merch_orders_for_show(show_id)
      |> Haj.Repo.preload([:user, merch_order_items: [:merch_item]])

    order_summary = Haj.Merch.get_merch_order_summary(show_id)

    assign(socket, orders: orders, order_summary: order_summary)
  end

  defp list_items(order) do
    Enum.map_join(
      order.merch_order_items,
      fn item -> "#{item.count} x #{item.merch_item.name}" end,
      ", "
    )
  end
end
