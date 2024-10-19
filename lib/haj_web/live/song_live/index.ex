defmodule HajWeb.SongLive.Index do
  use HajWeb, :live_view

  alias Haj.Archive
  alias Haj.Spex
  alias Haj.Policy

  def mount(_params, _session, socket) do
    show = Spex.current_spex()
    songs = Archive.list_songs_for_show(show.id)

    show_options =
      Spex.list_shows()
      |> Enum.map(fn %{id: id, year: year, title: title} ->
        [key: "#{year.year}: #{title}", value: id]
      end)

    authorized_admin = Policy.authorize?(:songs_edit, socket.assigns.current_user)

    {:ok,
     assign(socket,
       page_title: "Sånger",
       songs: songs,
       show: show,
       show_options: show_options,
       authorized_admin: authorized_admin
     )}
  end

  def handle_event("select_show", %{"show" => show_id}, socket) do
    show = Spex.get_show!(show_id)
    songs = Archive.list_songs_for_show(show.id)
    {:noreply, assign(socket, show: show, songs: songs)}
  end
end
