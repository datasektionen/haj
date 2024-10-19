defmodule HajWeb.DashboardLive.Index do
  use HajWeb, :live_view

  alias Haj.Policy
  alias Haj.Responsibilities
  alias Haj.Spex
  alias Haj.Merch

  def mount(_params, _session, socket) do
    current_show = Spex.current_spex()
    user_id = socket.assigns.current_user.id

    user_groups =
      Spex.get_show_groups_for_user(user_id)
      |> Enum.filter(fn %{show: show} -> show.id == current_show.id end)

    membership_meta =
      Enum.map(user_groups, fn %{id: id} -> id end) |> Spex.get_show_group_membership_metas()

    merch_order_items = Merch.get_current_merch_order_items(user_id)

    responsibilities =
      case Policy.authorize(:responsibility_read, socket.assigns.current_user) do
        :ok -> Responsibilities.get_current_responsibilities(user_id)
        _ -> []
      end

    {:ok,
     assign(socket,
       user_groups: user_groups,
       membership_meta: membership_meta,
       merch_order_items: merch_order_items,
       responsibilities: responsibilities,
       page_title: "Hem"
     )}
  end

  attr :order_item, Haj.Merch.MerchOrderItem

  defp merch_card(assigns) do
    ~H"""
    <.link
      patch={~p"/merch/#{@order_item.id}/edit"}
      class="group relative overflow-hidden rounded-lg border shadow-sm"
    >
      <%= if @order_item.merch_item.image do %>
        <img
          src={image_url(@order_item.merch_item.image, 800, 800)}
          alt={@order_item.merch_item.name}
          class="absolute inset-0 h-full w-full object-cover brightness-50 duration-300 ease-in-out group-hover:scale-105"
        />
      <% else %>
        <div class="bg-size-125 bg-pos-0 from-burgandy-400 to-burgandy-700 absolute inset-0 h-full w-full bg-gradient-to-br duration-300 ease-in-out group-hover:bg-pos-100" />
      <% end %>

      <div class="relative flex flex-col gap-1 px-4 py-4 sm:gap-1.5">
        <p class="text-lg font-bold text-gray-50"><%= @order_item.merch_item.name %></p>
        <p class="text-sm text-gray-200">
          Storlek <%= @order_item.size %>, <%= @order_item.count %> st
        </p>
      </div>
    </.link>
    """
  end

  defp get_role(user_id, show_group_id, membership_meta) do
    chefs = Map.get(membership_meta, show_group_id, %{chefs: []})[:chefs]

    case user_id in chefs do
      true -> "Chef"
      false -> "Gruppis"
    end
  end
end
