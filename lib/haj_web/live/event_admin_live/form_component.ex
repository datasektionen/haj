require Logger

defmodule HajWeb.EventAdminLive.FormComponent do
  use HajWeb, :live_component

  alias Haj.Events

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <.header>
          <%= @title %>
          <:subtitle>Use this form to manage event records in your database.</:subtitle>
        </.header>

        <.simple_form for={@form} id="event-form" phx-target={@myself} phx-submit="save">
          <.input field={@form[:name]} type="text" label="name" />
          <.input field={@form[:description]} type="text" label="description" />
          <.input field={@form[:image]} type="text" label="image" />
          <.input field={@form[:ticket_limit]} type="number" label="ticket_limit" />
          <.input field={@form[:purchase_deadline]} type="datetime-local" label="purchase_deadline" />
          <.input field={@form[:event_date]} type="datetime-local" label="event_date" />
          <!-- Spacer div since margin gets overwritten by external styles -->
          <div class="h-3" />
          <div>
            <h3>Ticket Types</h3>
            <.inputs_for :let={f_nested} field={@form[:ticket_types]}>
              <div class="mb-5">
                <div class="flex justify-between gap-2">
                  <div class="w-1/4">
                    <.input field={f_nested[:name]} type="text" label="name" />
                  </div>
                  <div class="w-1/4">
                    <.input field={f_nested[:price]} type="number" label="price" />
                  </div>
                  <div class="w-1/2">
                    <.input field={f_nested[:description]} type="text" label="description" />
                  </div>
                  <div>
                    <div class="h-[32px]" />
                    <.button phx-click="delete" phx-value-ticket={@myself}>Delete</.button>
                  </div>
                </div>
              </div>
            </.inputs_for>
          </div>

          <:actions>
            <.button phx-disable-with="Saving...">Save Event</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{event: event} = assigns, socket) do
    changeset = Events.change_event(event)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset =
      socket.assigns.event
      |> Events.change_event(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.action, event_params)
  end

  def handle_event("delete", %{"ticket" => ticket_type}, socket) do
    delete_ticket_type(socket, ticket_type)
  end

  defp save_event(socket, :edit, event_params) do
    case Events.update_event(socket.assigns.event, event_params, with_tickets: true) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_event(socket, :new, event_params) do
    case Events.create_event(event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp delete_ticket_type(socket, ticket_type) do
    case Events.delete_ticket_type(ticket_type) do
      {:ok, _ticket_type} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ticket type deleted successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
