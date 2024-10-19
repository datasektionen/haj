defmodule HajWeb.SettingsLive.Event.Index do
  use HajWeb, :live_view

  alias Haj.Events
  alias Haj.Events.Event
  alias Haj.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :events, list_events())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Redigera event")
    |> assign(:event, Events.get_event!(id) |> Repo.preload(:ticket_types))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nytt event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Event")
    |> assign(:event, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(id)
    {:ok, _} = Events.delete_event(event)

    {:noreply, assign(socket, :events, list_events())}
  end

  defp list_events do
    Events.list_events()
  end
end