defmodule HajWeb.EventLive.Index do
  use HajWeb, :live_view

  alias Haj.Events
  alias Haj.Events.Event
  alias Haj.Presence

  @impl true
  def mount(_params, _session, socket) do
    Events.subscribe()
    initial_count = Presence.list("custom_channel") |> map_size
    HajWeb.Endpoint.subscribe("custom_channel")

    Presence.track(
      self(),
      "custom_channel",
      socket.id,
      %{}
    )

    {:ok, assign(socket, events: list_events(), online_count: initial_count)}
  end

  @impl true
  def handle_info({Events, [:registration, _], _}, socket) do
    {:noreply, assign(socket, events: list_events())}
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{online_count: count}} = socket
      ) do
    online_count = count + map_size(joins) - map_size(leaves)
    {:noreply, assign(socket, :online_count, online_count)}
  end

  defp list_events do
    # Todo: maybe fetch in one query
    Events.list_events()
    |> Enum.map(fn event ->
      ticked_sold = Events.tickets_sold(event.id)
      Map.put(event, :availible, event.ticket_limit - ticked_sold)
    end)
  end

  @impl true
  def handle_event("register", %{"id" => id}, socket) do
    case Events.create_event_registration(%{
           "user_id" => socket.assigns.current_user.id,
           "ticket_type_id" => id
         }) do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Purchased")}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "Error")}
    end
  end

  defp ticket_format_date(event_date) do
    Calendar.strftime(event_date, "%d %B %Y")
  end

  defp ticket_format_time(event_date) do
    Calendar.strftime(event_date, "%H:%M")
  end

  defp online_count(assigns) do
    ~H"""
    <div class="justify my-10 flex items-center">
      <div class="bg-burgandy-400 mr-3 rounded px-5 py-1 text-center text-white">
        <p><%= max(@online_count - 1, 0) %></p>
      </div>
      <p class="h-min">andra metaloger som väntar på biljetter</p>
    </div>
    """
  end

  defp month_name(month) do
    {"januari", "februari", "mars", "april", "maj", "juni", "juli", "augusti", "september",
     "oktober", "november", "december"}
    |> elem(month - 1)
  end

  defp event_card(assigns) do
    ~H"""
    <.link navigate={~p"/events/#{@event}"}>
      <div class="relative mx-0 flex h-64 flex-col overflow-hidden rounded-xl bg-white shadow-lg duration-150 hover:bg-gray-50">
        <div class="r h-2/3 overflow-hidden">
          <img
            src={@event.image}
            alt={"Picture of #{@event.name}"}
            class="tmt relative right-0 left-0 w-full object-cover p-0"
          />
        </div>
        <div class="absolute top-4 right-4 rounded-md bg-white px-2 py-1">
          Priser från <span class="font-bold">128 kr</span>
        </div>

        <div class="flex w-full flex-row items-center justify-between bg-inherit p-4">
          <div class="flex flex-col">
            <div class="text-xl font-bold"><%= @event.name %></div>
            <div class="text-gray-500">
              <%= Calendar.strftime(@event.event_date, "%d %B %H:%M", month_names: &month_name/1) %>
            </div>
          </div>
        </div>
      </div>
    </.link>

    <%!--
             <Link to={`event/${props.event.id}`}>
            <div className="relative flex flex-col rounded-xl h-64 w-full mx-0 overflow-hidden shadow-lg bg-white hover:bg-gray-50 duration-150">
              <img
                src={props.event.eventPictureLink}
                className="object-cover relative"
              />
              <div className="absolute top-4 right-4 bg-white px-2 py-1 rounded-md">
                Priser från <span className="font-bold">{props.event.price} kr</span>
              </div>
              <div className="absolute bottom-0 left-0 right-0 bg-inherit w-full flex flex-row justify-between px-4 py-4">
                <div className="flex flex-col ">
                  <div className="font-bold text-xl ">{props.event.shortTitle}</div>
                  <div className="text-gray-500">{props.event.location.title}</div>
                  <div className="text-gray-500">{`${props.event.startTime
                    .toTimeString()
                    .substr(0, 5)}`}</div>
                </div>
                <div className="self-center bg-gray-200 rounded-full flex flex-col items-center justify-center w-16 h-16">
                  <span> {props.event.startTime.getDate()}</span>
                  <span>
                    {props.event.startTime.toLocaleString("sv-SE", {
                      month: "short",
                    })}{" "}
                  </span>
                </div>
              </div>
            </div>
            </Link>  --%>
    <%!--     <section class="mt-10 flex max-w-3xl">
              <div class="relative h-60 w-60">
                <img class="z-0 h-full w-full" src={@event.image} />
                <div class="align-center absolute bottom-0 z-10 flex h-1/3 w-full flex-col justify-center bg-black p-5 opacity-75">
                  <p class="text-2xl text-white"><%= @event.availible %></p>
                  <p class="text-white">Available tickets</p>
                </div>
              </div>
              <div class="ml-5 flex-1">
                <div>
                  <div class="mb-5 flex place-content-between">
                    <h3 class="text-3xl"><%= @event.name %></h3>
                    <div>
                      <div><%= ticket_format_date(@event.event_date) %></div>
                      <div><%= ticket_format_time(@event.event_date) %></div>
                    </div>
                  </div>
                  <div><%= @event.description %></div>
                </div>
              </div>
              <nav>
                <%= for ticket_type <- @event.ticket_types do %>
                  <div><%= ticket_type.name %></div>
                  <div><%= ticket_type.price %></div>
                  <div><%= ticket_type.description %></div>
                  <button type="button" phx-click={JS.push("register", value: %{id: ticket_type.id})}>
                    Köp
                  </button>
                <% end %>
              </nav>
            </section> --%>
    """
  end
end
