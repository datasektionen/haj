defmodule HajWeb.DashboardLive.Index do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Merch

  def mount(_params, _session, socket) do
    current_show = Spex.current_spex()
    user_id = socket.assigns.current_user.id

    user_groups =
      Spex.get_show_groups_for_user(user_id)
      |> Enum.filter(fn %{show: show} -> show.id == current_show.id end)

    merch_order_items = Merch.get_current_merch_order_items(user_id)

    {:ok,
     assign(socket,
       user_groups: user_groups,
       merch_order_items: merch_order_items,
       page_title: "Hem"
     )}
  end

  defp group_card(assigns) do
    ~H"""
    <.link
      navigate={~p"/live/group/#{@show_group.id}"}
      class="flex flex-col gap-1 rounded-lg border px-4 py-4 shadow-sm hover:bg-gray-50 sm:gap-1.5"
    >
      <div class="text-burgandy-500 inline-flex items-center gap-2 text-lg font-bold">
        <.icon name={:user_group} solid />
        <span class="">
          <%= @show_group.group.name %>
        </span>
      </div>
      <div class="text-gray-500">
        <%= length(@show_group.group_memberships) %> medlemmar
      </div>
      <div>
        Du är <%= @role %>
      </div>
    </.link>
    """
  end

  defp merch_card(assigns) do
    ~H"""
    <.link
      patch={~p"/live/merch/#{@order_item.id}/edit"}
      class="group relative overflow-hidden rounded-lg border shadow-sm"
    >
      <%= if @order_item.merch_item.image do %>
        <img
          src={Imgproxy.new(@order_item.merch_item.image) |> Imgproxy.resize(800, 800) |> to_string()}
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
end
