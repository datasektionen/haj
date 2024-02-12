defmodule HajWeb.EventLive.Show do
  use HajWeb, :live_view

  alias Haj.Events
  alias Haj.Presence

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    initial_count = Presence.list("present:event:#{id}") |> map_size

    if connected?(socket) do
      Events.subscribe(id)
      HajWeb.Endpoint.subscribe("present:event:#{id}")

      Presence.track(
        self(),
        "present:event:#{id}",
        socket.id,
        %{}
      )
    end

    event = Events.get_event!(id)

    {:ok,
     assign(socket,
       event: event,
       online_count: initial_count,
       price: 0
     )
     |> assign_selected_tickets(event.ticket_types)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply, assign(socket, event: Events.get_event!(id))}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{online_count: count}} = socket
      ) do
    online_count = count + map_size(joins) - map_size(leaves)
    {:noreply, assign(socket, :online_count, online_count)}
  end

  @impl true
  def handle_info({Events, _, _}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("inc", %{"id" => id}, socket) do
    selected = Map.update(socket.assigns.selected, id, 0, &(&1 + 1))
    price = socket.assigns.price + socket.assigns.ticket_types[id].price

    {:noreply, assign(socket, selected: selected, price: price)}
  end

  @impl true
  def handle_event("dec", %{"id" => id}, socket) do
    selected = Map.update(socket.assigns.selected, id, 0, &(&1 - 1))
    price = socket.assigns.price - socket.assigns.ticket_types[id].price

    {:noreply, assign(socket, selected: selected, price: price)}
  end

  @impl true
  def handle_event("register", _, socket) do
    if socket.assigns.event.has_tickets do
      selected = Enum.filter(socket.assigns.selected, fn {_, count} -> count > 0 end)
      IO.inspect(selected)
      {:noreply, socket}
    else
      {:noreply, push_patch(socket, to: ~p"/events/#{socket.assigns.event}/register")}
    end
  end

  defp assign_selected_tickets(socket, ticket_types) do
    socket
    |> assign_new(:selected, fn ->
      Map.new(ticket_types, fn %{id: id} -> {id, 0} end)
    end)
    |> assign_new(:ticket_types, fn ->
      Map.new(ticket_types, fn %{id: id} = tt -> {id, tt} end)
    end)
  end

  defp toggle_mobile_tickets(js \\ %JS{}) do
    js
    |> JS.toggle_class("hidden", to: "#tickets")
    |> JS.toggle_class("flex", to: "#tickets")
    |> JS.toggle_class("hidden", to: "#bottom-bar")
  end
end
