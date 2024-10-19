defmodule HajWeb.SongLive.Show do
  use HajWeb, :live_view

  alias Haj.Archive
  alias Haj.Repo

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    song =
      Archive.get_song!(id)
      |> Repo.preload(:show)

    lyrics = parse_lyrics(song.text)

    {:noreply,
     assign(socket,
       page_title: song.name,
       song: song,
       lyrics: lyrics,
       player: false,
       loaded: false
     )}
  end

  def handle_event("play_pause", _params, socket) do
    {:noreply, assign(socket, playing: !socket.assigns.playing) |> push_event("play_pause", %{})}
  end

  def handle_event("load", _params, socket) do
    song = socket.assigns.song

    {:noreply,
     assign(socket, player: true, playing: false)
     |> push_event("load", %{timings: song.line_timings, url: Haj.S3.s3_url(song.file)})}
  end

  def handle_event("loaded", _params, socket) do
    {:noreply, assign(socket, loaded: true)}
  end

  def handle_event("jump", %{"index" => index}, socket) do
    {:noreply, push_event(socket, "jump", %{line: index})}
  end

  def handle_event("js_paused", _params, socket) do
    {:noreply, assign(socket, playing: false)}
  end

  defp js_play_pause() do
    JS.push("play_pause") |> JS.dispatch("js:play_pause", to: "#audio-player")
  end

  defp parse_lyrics(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
