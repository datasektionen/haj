require Logger

defmodule HajWeb.SettingsLive.Event.FormComponent do
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
          <:subtitle>Redigera event.</:subtitle>
        </.header>

        <.simple_form
          for={@form}
          id="event-form"
          phx-target={@myself}
          phx-submit="save"
          phx-change="validate"
        >
          <.input field={@form[:name]} type="text" label="Namn" />
          <.input field={@form[:description]} type="text" label="Beskrivning" />
          <.input field={@form[:ticket_limit]} type="number" label="Biljettgräns" />
          <.input field={@form[:event_date]} type="datetime-local" label="Datum" />
          <.input field={@form[:purchase_deadline]} type="datetime-local" label="Köpdeadline" />
          <.input field={@form[:image]} type="text" label="Bild" />

          <div class="space-y-4">
            <h3 class="text-lg font-semibold leading-8 text-zinc-800">Biljettyper</h3>
            <.inputs_for :let={f_nested} field={@form[:ticket_types]}>
              <input type="hidden" name="event[tickets_sort][]" value={f_nested.index} />
              <div class="flex justify-between gap-2">
                <div class="w-1/4">
                  <.input field={f_nested[:name]} type="text" label="Namn" />
                </div>
                <div class="w-1/4">
                  <.input field={f_nested[:price]} type="number" label="Pris" />
                </div>
                <div class="w-1/2">
                  <.input field={f_nested[:description]} type="text" label="Beskrivning" />
                </div>
                <div>
                  <div class="h-[32px]" />
                  <button
                    name="event[tickets_drop][]"
                    value={f_nested.index}
                    phx-click={JS.dispatch("change")}
                    type="button"
                  >
                    <.icon name={:x_mark} class="relative top-2 h-6 w-6" />
                  </button>
                </div>
              </div>
            </.inputs_for>

            <input type="hidden" name="event[tickets_drop][]" />

            <div class="flex justify-start">
              <button
                type="button"
                class="flex flex-row items-center gap-2 text-sm text-zinc-600"
                phx-target={@myself}
                name="event[tickets_sort][]"
                value="new"
                phx-click={JS.dispatch("change")}
              >
                <.icon name={:plus_circle} class="h-5 w-5" /> Ny biljettyp
              </button>
            </div>
          </div>

          <:actions>
            <.button phx-disable-with="Saving...">Spara event</.button>
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
      |> Events.change_event(event_params, with_tickets: true)
      |> Map.put(:action, :validate)

    IO.inspect(assign_form(socket, changeset))

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
    case Events.create_event(event_params, with_tickets: true) do
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
