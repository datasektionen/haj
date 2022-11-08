defmodule HajWeb.MerchAdminLive.Index do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Merch

  def mount(_params, _session, socket) do
    show = Spex.current_spex()

    show_options =
      Spex.list_shows()
      |> Enum.map(fn %{id: id, year: year, title: title} ->
        [key: "#{year.year}: #{title}", value: id]
      end)

    merch_items = Merch.list_merch_items_for_show(show.id)

    changesets =
      merch_items
      |> Enum.sort_by(& &1.inserted_at, {:desc, Time})
      |> Enum.map(&Merch.change_merch_item/1)

    socket =
      socket
      |> assign(
        show: show,
        show_options: show_options,
        changesets: changesets
      )

    {:ok, socket}
  end

  def handle_info({:updated_changeset, :new, changeset}, socket) do
    changesets =
      Enum.map(socket.assigns.changesets, fn old ->
        case old.data.temp_id == changeset.data.temp_id do
          true -> changeset
          false -> old
        end
      end)

    {:noreply, assign(socket, changesets: changesets)}
  end

  def handle_info({:updated_changeset, :edit, changeset}, socket) do
    changesets =
      Enum.map(socket.assigns.changesets, fn old ->
        case old.data.id == changeset.data.id do
          true -> changeset
          false -> old
        end
      end)

    {:noreply, assign(socket, changesets: changesets)}
  end

  def handle_info({:created_merch, merch, temp_id}, socket) do
    # Delete the temporary one with the created item
    changesets =
      Enum.map(socket.assigns.changesets, fn changeset ->
        case changeset.data.temp_id == temp_id do
          true -> Merch.change_merch_item(merch)
          false -> changeset
        end
      end)

    {:noreply, assign(socket, changesets: changesets)}
  end

  def handle_info({:removed_merch, temp_id}, socket) do
    changesets =
      Enum.filter(socket.assigns.changesets, fn changeset ->
        changeset.data.temp_id != temp_id
      end)

    {:noreply, assign(socket, changesets: changesets)}
  end

  def handle_info({:deleted_merch, merch_item_id}, socket) do
    changesets =
      Enum.filter(socket.assigns.changesets, fn changeset ->
        changeset.data.id != merch_item_id
      end)

    {:noreply, assign(socket, changesets: changesets)}
  end

  def handle_event("select_show", %{"show" => %{"show" => show_id}}, socket) do
    show = Spex.get_show!(show_id)
    merch_items = Merch.list_merch_items_for_show(show.id)
    changesets = merch_items |> Enum.map(&Merch.change_merch_item/1)

    {:noreply, assign(socket, show: show, changesets: changesets)}
  end

  def handle_event("add_merch", _params, socket) do
    changeset = Merch.change_merch_item(%Merch.MerchItem{temp_id: get_temp_id()})

    {:noreply, assign(socket, changesets: [changeset | socket.assigns.changesets])}
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

  def render(assigns) do
    ~H"""
    <div class="pb-4 border-b">
      <h3 class="font-bold text-2xl py-2">Administrera merch</h3>
      <.form :let={f} for={:show} phx-change="select_show" class="">
        <div class="">
          <%= label(f, :show, "Välj spex", class: "input-label") %>
          <div class="flex flex-row gap-4">
            <%= select(f, :show, @show_options, class: "input") %>
            <div class="flex justify-end mt-1 flex-shrink-0">
              <button
                type="button"
                class="h-full rounded-md border border-transparent py-2 px-4 bg-burgandy-500 text-sm font-medium text-white shadow-sm
                hover:bg-burgandy-600 focus:outline-none focus:ring-2 focus:ring-burgandy-500 focus:ring-offset-2"
                phx-click="add_merch"
              >
                Ny merch
              </button>
            </div>
          </div>
        </div>
      </.form>
    </div>

    <div class="grid gap-6 pt-4 xl:grid-cols-2">
      <%= for changeset <- @changesets do %>
        <.live_component
          module={HajWeb.MerchAdminLive.FormComponent}
          id={"form_#{changeset.data.id}_#{changeset.data.temp_id}"}
          changeset={changeset}
          flash={@flash}
          show_id={@show.id}
        />
      <% end %>
    </div>
    """
  end
end
