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
      class="flex flex-col gap-1 sm:gap-1.5 border rounded-lg shadow-sm px-4 py-4 hover:bg-gray-50"
    >
      <div class="text-lg font-bold text-burgandy-500 inline-flex items-center gap-2">
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
      class="border rounded-lg shadow-sm group overflow-hidden relative"
    >
      <%= if @order_item.merch_item.image do %>
        <img
          src={Imgproxy.new(@order_item.merch_item.image) |> Imgproxy.resize(800, 800) |> to_string()}
          alt={@order_item.merch_item.name}
          class="object-cover w-full h-full brightness-50 absolute inset-0
               ease-in-out duration-300 group-hover:scale-105"
        />
      <% else %>
        <div class="w-full h-full absolute inset-0 ease-in-out duration-300 bg-size-125 bg-pos-0 group-hover:bg-pos-100
                    bg-gradient-to-br from-burgandy-400 to-burgandy-700" />
      <% end %>

      <div class="relative px-4 py-4 flex flex-col gap-1 sm:gap-1.5">
        <p class="font-bold text-lg text-gray-50"><%= @order_item.merch_item.name %></p>
        <p class="text-gray-200 text-sm">
          Storlek <%= @order_item.size %>, <%= @order_item.count %> st
        </p>
      </div>
    </.link>
    """
  end
end
