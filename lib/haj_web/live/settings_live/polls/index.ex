defmodule HajWeb.SettingsLive.Poll.Index do
  use HajWeb, :live_view

  alias Haj.Polls
  alias Haj.Polls.Poll

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :poll_collection, Polls.list_polls())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Poll")
    |> assign(:poll, Polls.get_poll!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Poll")
    |> assign(:poll, %Poll{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Poll")
    |> assign(:poll, nil)
  end

  @impl true
  def handle_info({HajWeb.PollLive.FormComponent, {:saved, poll}}, socket) do
    {:noreply, stream_insert(socket, :poll_collection, poll)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    poll = Polls.get_poll!(id)
    {:ok, _} = Polls.delete_poll(poll)

    {:noreply, stream_delete(socket, :poll_collection, poll)}
  end
end
