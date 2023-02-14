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
      <div class="flex items-center justify my-10">
        <div class="mr-3 px-5 py-1 text-center bg-burgandy-400 text-white rounded">
          <p><%= max(@online_count - 1, 0) %></p>
        </div>
        <p class="h-min">andra metaloger som väntar på biljetter</p>
      </div>
    """
  end

  defp event_card(assigns) do
    ~H"""
    <section class="flex mt-10 max-w-3xl">
      <div class="relative w-60 h-60">
        <img
          class="w-full h-full z-0"
          src="https://scontent.fume1-1.fna.fbcdn.net/v/t1.6435-9/180978949_314228950059549_1005358403722529104_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=OV5A6IRvacEAX-IYTns&_nc_ht=scontent.fume1-1.fna&oh=00_AfCKCCvvZrn9SkGwJMxWgbZ7fs7Z67TTvCQshL7xSgdXpA&oe=63D1628E"
        />
        <div class="absolute flex flex-col justify-center align-center w-full h-1/3 bottom-0 bg-black opacity-75 z-10 p-5">
          <p class="text-white text-2xl"><%= @event.availible %></p>
          <p class="text-white">Available tickets</p>
        </div>
      </div>
      <div class="flex-1 ml-5">
        <div>
          <div class="flex place-content-between mb-5">
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
    </section>
    <hr />
    """
  end
end
