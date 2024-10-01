defmodule HajWeb.SongLive.Edit.Show do
  use HajWeb, :live_view

  alias Haj.Archive
  on_mount {HajWeb.UserAuth, {:authorize, :songs_edit}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:song, Archive.get_song!(id))}
  end

  defp page_title(:show), do: "Show Song"
  defp page_title(:edit), do: "Edit Song"
end
