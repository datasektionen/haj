defmodule HajWeb.SongLive.Show do
  use HajWeb, :live_view

  alias Haj.Archive
  alias Haj.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    song =
      Archive.get_song!(id)
      |> Repo.preload(:show)

    lyrics = parse_lyrics(song.text)

    {:noreply, assign(socket, song: song, lyrics: lyrics, loaded: false)}
  end

  def handle_event("play", _params, socket) do
    {:noreply, assign(socket, playing: !socket.assigns.playing) |> push_event("play_pause", %{})}
  end

  def handle_event("load", _params, socket) do
    {:noreply,
     assign(socket, loaded: true, playing: false)
     |> push_event("load", %{timings: socket.assigns.song.line_timings})}
  end

  def handle_event("jump", %{"index" => index}, socket) do
    {:noreply, push_event(socket, "jump", %{line: index})}
  end

  defp parse_lyrics(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
