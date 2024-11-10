defmodule HajWeb.SettingsLive.Option.Show do
  use HajWeb, :live_view

  alias Haj.Polls

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:option, Polls.get_option!(id))}
  end

  defp page_title(:show), do: "Show Option"
  defp page_title(:edit), do: "Edit Option"
end
