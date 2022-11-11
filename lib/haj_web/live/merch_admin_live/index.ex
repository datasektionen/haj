defmodule HajWeb.MerchAdminLive.Index do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Merch
  alias Haj.Merch.MerchItem

  @impl true
  def mount(params, _session, socket) do
    show =
      case params do
        %{"show" => show_id} -> Spex.get_show!(show_id)
        _ -> Spex.current_spex()
      end

    show_options =
      Spex.list_shows()
      |> Enum.map(fn %{id: id, year: year, title: title} ->
        [key: "#{year.year}: #{title}", value: id]
      end)

    merch_items =
      Merch.list_merch_items_for_show(show.id)
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})

    socket =
      socket
      |> assign(
        show: show,
        show_options: show_options,
        merch_items: merch_items
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Redigera Merch")
    |> assign(:merch_item, Merch.get_merch_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Ny Merch")
    |> assign(:merch_item, %MerchItem{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Visar Merch")
    |> assign(:merch_item, nil)
  end

  def handle_event("select_show", %{"show" => %{"show" => show_id}}, socket) do
    show = Spex.get_show!(show_id)

    merch_items =
      Merch.list_merch_items_for_show(show.id)
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})

    {:noreply, assign(socket, merch_items: merch_items, show: show)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    merch_item = Merch.get_merch_item!(id)
    {:ok, _} = Merch.delete_merch_item(merch_item)

    merch_items =
      Merch.list_merch_items_for_show(socket.assigns.show.id)
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})

    {:noreply, assign(socket, :merch_items, merch_items)}
  end

  defp field(assigns) do
    ~H"""
    <div class="border-b pt-2 pb-2">
      <span class="text-sm text-gray-500 block pb-1"><%= @title %></span>
      <span class="text-sm block whitespace-pre-line"><%= @text %></span>
    </div>
    """
  end
end
