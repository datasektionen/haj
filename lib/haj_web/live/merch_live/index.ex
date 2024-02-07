defmodule HajWeb.MerchLive.Index do
  use HajWeb, :live_view

  alias Haj.Merch
  alias Haj.Spex

  on_mount {HajWeb.UserAuth, {:authorize, :merch_buy}}

  @impl true
  def mount(_params, _session, socket) do
    show = Spex.current_spex()
    available_merch = Merch.list_merch_items_for_show(show.id)
    ordered_items = Merch.get_current_merch_order_items(socket.assigns.current_user.id)

    {:ok,
     assign(socket, show: show, available_merch: available_merch, ordered_items: ordered_items)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"merch_order_item_id" => id}) do
    merch_order_item = Merch.get_merch_order_item!(id) |> Haj.Repo.preload(:merch_order)

    case merch_order_item.merch_order.user_id == socket.assigns.current_user.id do
      true ->
        socket
        |> assign(:page_title, "Redigera beställning")
        |> assign(:merch_order_item, merch_order_item)
        |> assign(:merch_item, Merch.get_merch_item!(merch_order_item.merch_item_id))

      false ->
        socket
        |> put_flash(:error, "Du kan inte redigera andras beställningar!")
        |> push_navigate(to: ~p"/merch/")
    end
  end

  defp apply_action(socket, :new, %{"merch_item_id" => id}) do
    socket
    |> assign(:page_title, "Ny beställning")
    |> assign(:merch_item, Merch.get_merch_item!(id))
    |> assign(:merch_order_item, %Merch.MerchOrderItem{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Merch")
    |> assign(:merch_order_item, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    merch_order_item = Merch.get_merch_order_item!(id)

    case Merch.delete_merch_order_item(merch_order_item) do
      {:ok, _} ->
        ordered_items = Merch.get_current_merch_order_items(socket.assigns.current_user.id)

        {:noreply, assign(socket, ordered_items: ordered_items)}

      {:error, message} ->
        {:noreply, socket |> put_flash(:error, message)}
    end
  end

  defp merch_item_card(assigns) do
    ~H"""
    <.link
      patch={~p"/merch/new?merch_item_id=#{@item.id}"}
      class="group relative overflow-hidden rounded-lg border px-4 py-6 shadow-sm"
    >
      <%= if @item.image do %>
        <img
          src={Imgproxy.new(@item.image) |> Imgproxy.resize(800, 800) |> to_string()}
          alt={@item.name}
          class="absolute inset-0 h-full w-full object-cover brightness-50 bg-white duration-300 ease-in-out group-hover:scale-105"
        />
      <% else %>
        <div class="bg-size-125 bg-pos-0 from-burgandy-400 to-burgandy-800 absolute inset-0 h-full w-full bg-gradient-to-br duration-300 ease-in-out group-hover:bg-pos-100" />
      <% end %>
      <div class="relative flex flex-col gap-1.5 sm:gap-2">
        <p class="text-lg font-bold text-gray-50"><%= @item.name %></p>
        <p class="text-sm text-gray-300 md:text-base"><%= @item.price %> kr</p>
        <%= if @item.purchase_deadline do %>
          <p class="text-sm text-gray-300 md:text-base">
            Beställningsdeadline <%= Calendar.strftime(@item.purchase_deadline, "%d/%m %Y") %>
          </p>
        <% end %>
      </div>
    </.link>
    """
  end

  defp merch_order_item_card(assigns) do
    ~H"""
    <div class="rounded-lg border px-4 py-4 hover:bg-gray-50">
      <div class="flex flex-row items-start justify-between gap-1">
        <p class="font-bold"><%= @order_item.merch_item.name %></p>
        <div class="flex flex-row justify-end gap-1">
          <.link patch={~p"/merch/#{@order_item.id}/edit"}>
            <Heroicons.pencil_square mini class="h-5 w-5 fill-gray-700 hover:fill-black" />
          </.link>
          <.link
            phx-click={JS.push("delete", value: %{id: @order_item.id})}
            data-confirm="Är du säker?"
          >
            <Heroicons.trash mini class="h-5 w-5 fill-gray-700 hover:fill-burgandy-500" />
          </.link>
        </div>
      </div>
      <p class="pt-2 text-gray-500"><%= @order_item.count %> st i storlek <%= @order_item.size %></p>
    </div>
    """
  end
end
