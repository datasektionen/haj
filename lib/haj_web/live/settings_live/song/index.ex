defmodule HajWeb.SettingsLive.Song.Index do
  use HajWeb, :live_view

  alias Haj.Archive
  alias Haj.Archive.Song
  alias Haj.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :songs, Archive.list_songs() |> Repo.preload(:show))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Redigera sång")
    |> assign(:song, Archive.get_song!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New sång")
    |> assign(:song, %Song{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Sånger")
    |> assign(:song, nil)
  end

  @impl true
  def handle_info({HajWeb.SettingsLive.Song.FormComponent, {:saved, song}}, socket) do
    {:noreply, stream_insert(socket, :songs, song |> Repo.preload(:show))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    song = Archive.get_song!(id)
    {:ok, _} = Archive.delete_song(song)

    {:noreply, stream_delete(socket, :songs, song)}
  end
end
