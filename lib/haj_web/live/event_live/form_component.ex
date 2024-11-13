defmodule HajWeb.EventLive.FormComponent do
  use HajWeb, :live_component
  alias Haj.Forms
  alias Haj.Events

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @form.name %>
        <:subtitle><%= @form.description %></:subtitle>
      </.header>
      <.form
        :let={form}
        for={@response_form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
        class="mt-4 flex flex-col gap-4"
      >
        <HajWeb.CoreComponents.label :if={@event.has_tickets}>
          Biljett
        </HajWeb.CoreComponents.label>
        <.radio_group :if={@event.has_tickets} field={form[:ticket_type_id]}>
          <:radio :for={ticket <- @event.ticket_types} value={ticket.id}>
            <div>
              <div class="font-medium"><%= ticket.name %></div>
              <div class="text-sm text-gray-800">
                <p :if={ticket.price == 0}>Gratis</p>
                <p :if={ticket.price != 0}><%= ticket.price %> kr</p>
              </div>
            </div>
          </:radio>
        </.radio_group>

        <.input
          name="attending"
          type="select"
          options={[{"Ja", true}, {"Nej", false}]}
          label="Kommer du"
          value={@attending}
        />

        <.form_input
          :for={question <- @form.questions}
          question={question}
          field={@response_form[String.to_atom("#{question.id}")]}
        />

        <div>
          <.button phx-disable-with="Sparar...">Spara</.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{event: event, current_user: user} = assigns, socket) do
    registration = Events.get_registration_for_user(event.id, user.id)
    attending = registration && registration.attending && true

    socket = assign(socket, registration: registration)

    assigns =
      if event.form do
        form_response = Forms.get_event_response_for_user(event.id, user.id)

        changeset = Forms.get_form_changeset!(event.form_id, form_response || %{})
        form = Forms.get_form!(event.form_id)

        changeset =
          if registration,
            do: Ecto.Changeset.cast(changeset, Map.from_struct(registration), []),
            else: changeset

        assign(socket, assigns)
        |> assign(form: form)
        |> assign_form(changeset)
      else
        assign(socket, assigns)
        |> assign(
          form: %{name: "Anmälan", description: "Anmäl dig till #{event.name}", questions: []},
          response_form: to_form(%{})
        )
      end

    {:ok,
     assigns
     |> assign(price: 0, attending: attending)
     |> assign_selected_tickets(event.ticket_types)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"form_response" => response, "attending" => attending},
        socket
      ) do
    # We need to flatten all multi-responses to a list
    response = flatten_response(response)

    changeset =
      Forms.get_form_changeset!(socket.assigns.form.id, response) |> Map.put(:action, :validate)

    {:noreply, assign(socket, attending: attending) |> assign_form(changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"attending" => attending},
        socket
      ) do
    {:noreply, assign(socket, attending: attending)}
  end

  @impl true
  def handle_event("save", %{"form_response" => response, "attending" => attending}, socket) do
    ticket_id = Map.get(response, "ticket_type_id", nil)

    response =
      Map.delete(response, "ticket_type_id")
      |> flatten_response()

    {:noreply,
     assign(socket, attending: attending, ticket_id: ticket_id)
     |> save(socket.assigns.registration, response)}
  end

  @impl true
  def handle_event("save", %{"attending" => attending}, socket) do
    {:noreply, assign(socket, attending: attending) |> save(socket.assigns.registration)}
  end

  defp save(socket, nil, response) do
    %{current_user: user, event: event, attending: attending, ticket_id: ticket_id} =
      socket.assigns

    with {:ok, form_response} <-
           Forms.submit_form(socket.assigns.form.id, user.id, response),
         {:ok, _} <-
           Events.create_event_registration(%{
             event_id: event.id,
             user_id: user.id,
             response_id: form_response[:response].id,
             attending: attending,
             ticket_type_id: ticket_id
           }) do
      push_flash(:info, "Du är nu anmäld!")
      push_patch(socket, to: socket.assigns.patch)
    else
      {:error, changeset} ->
        dbg(changeset)
        push_flash(:error, "Något gick fel.")
        assign_form(socket, changeset)

      a ->
        dbg(a)
        IO.inspect("error")
        push_flash(:error, "Något gick fel.")
    end
  end

  defp save(socket, registration, response) do
    %{current_user: user, attending: attending, ticket_id: ticket_id} = socket.assigns

    dbg(socket.assigns.registration)
    dbg(socket.assigns.form)

    with previous when not is_nil(previous) <-
           Forms.get_event_response_for_user(socket.assigns.registration.event_id, user.id),
         {:ok, _} <-
           Forms.update_form_response(socket.assigns.form.id, previous, response),
         {:ok, _} <-
           Events.update_event_registration(registration, %{
             form_response_id: previous.id,
             attending: attending,
             ticket_type_id: ticket_id
           }) do
      push_flash(:info, "Uppdaterade anmälan!")
      push_patch(socket, to: socket.assigns.patch)
    else
      nil ->
        dbg(response)
        push_flash(:error, "Något gick fel.")
        socket

      {:error, changeset} ->
        dbg(changeset)
        push_flash(:error, "Något gick fel.")
        assign_form(socket, changeset)
    end
  end

  defp save(socket, nil) do
    %{current_user: user, event: event, attending: attending} = socket.assigns

    case Events.create_event_registration(%{
           event_id: event.id,
           user_id: user.id,
           attending: attending
         }) do
      {:ok, _} ->
        push_flash(:info, "Du är nu anmäld!")
        push_patch(socket, to: socket.assigns.patch)

      {:error, changeset} ->
        push_flash(:error, "Något gick fel.")
        assign_form(socket, changeset)
    end
  end

  defp save(socket, registration) do
    case Events.update_event_registration(registration, %{attending: socket.assigns.attending}) do
      {:ok, _} ->
        push_flash(:info, "Du är nu anmäld!")
        push_patch(socket, to: socket.assigns.patch)

      {:error, changeset} ->
        push_flash(:error, "Något gick fel.")
        assign_form(socket, changeset)
    end
  end

  defp flatten_response(response) do
    Enum.reduce(response, response, fn {q, a}, acc ->
      case a do
        a when is_map(a) ->
          list = Map.filter(a, fn {_, sel} -> sel == "true" end) |> Map.keys()
          Map.put(acc, q, list)

        _ ->
          acc
      end
    end)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :response_form, to_form(changeset, as: :form_response))
  end

  defp assign_selected_tickets(socket, ticket_types) do
    socket
    |> assign_new(:ticket_types, fn ->
      Map.new(ticket_types, fn %{id: id} = tt -> {id, tt} end)
    end)
  end
end
