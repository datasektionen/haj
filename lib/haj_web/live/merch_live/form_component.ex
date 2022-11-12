defmodule HajWeb.MerchLive.FormComponent do
  use HajWeb, :live_component

  alias Haj.Merch

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        :let={f}
        for={@changeset}
        id="merch-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :size}} label="Storlek" type="select" options={@merch_item.sizes} />
        <.input field={{f, :count}} label="Antal" type="number" />

        <:actions>
          <.button phx-disable-with="Sparar...">Spara</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{merch_order_item: merch_order_item} = assigns, socket) do
    changeset = Merch.change_merch_order_item(merch_order_item)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"merch_order_item" => params}, socket) do
    changeset =
      socket.assigns.merch_order_item
      |> Merch.change_merch_order_item(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"merch_order_item" => params}, socket) do
    save_merch_order_item(socket, socket.assigns.action, params)
  end

  defp save_merch_order_item(socket, :new, params) do
    show_id = socket.assigns.show.id
    user_id = socket.assigns.current_user.id
    merch_item_id = socket.assigns.merch_item.id

    case Merch.add_merch_order_item_to_order(show_id, user_id, merch_item_id, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}

      {:error, message} ->
        push_flash(:error, message)
        {:noreply, socket}
    end
  end

  defp save_merch_order_item(socket, :edit, params) do
    merch_order_item = socket.assigns.merch_order_item
    show_id = socket.assigns.show.id
    user_id = socket.assigns.current_user.id

    case Merch.change_order_item_in_order(merch_order_item, show_id, user_id, params) do
      {:ok, _item} ->
        {:noreply, socket |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}

      {:error, message} ->
        push_flash(:error, message)
        {:noreply, socket}
    end
  end
end
