defmodule HajWeb.EventLive.Show do
  use HajWeb, :live_view

  alias Haj.Events
  alias Haj.Events.Event

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    event = Events.get_event!(id)

    {:ok, assign(socket, event: event)}
  end

  @impl true
  def handle_info({Events, _, _}, socket) do
    {:noreply, socket}
  end
end
