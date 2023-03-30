defmodule HajWeb.SettingsLive.Event.Show do
  use HajWeb, :live_view

  alias Haj.Events

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    event = Events.get_event!(id)
    {:ok, assign(socket, event: event)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:food, Events.get_event!(id))}
  end

  defp page_title(:show), do: "Mat"
  defp page_title(:edit), do: "Redigera mat"
end
