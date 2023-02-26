defmodule HajWeb.SettingsLive.Show.Show do
  use HajWeb, :live_view

  alias Haj.Spex

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:show, Spex.get_show!(id))}
  end

  defp page_title(:show), do: "Visa spex"
  defp page_title(:edit), do: "Redigera spex"
end
