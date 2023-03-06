defmodule HajWeb.GoogleTestLive do
  alias Haj.GoogleApi
  use HajWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("folder_selected", %{"file_id" => file_id}, socket) do
    {:ok, token} = GoogleApi.get_acess_token(socket.assigns.current_user.id)

    GoogleApi.create_sheet_file(file_id, "from_elixir", token)

    {:noreply, socket}
  end

  def handle_event("authorize", _params, socket) do
    {:ok, token} = GoogleApi.get_acess_token(socket.assigns.current_user.id)

    {:noreply, push_event(socket, "create_clientside_picker", %{token: token})}
  end

  def render(assigns) do
    ~H"""
    <button id="authorize_button" phx-hook="AuthorizeGoogle" phx-click="authorize">Authorize</button>
    <button id="signout_button" onclick="handleSignoutClick()">Sign Out</button>
    """
  end
end
