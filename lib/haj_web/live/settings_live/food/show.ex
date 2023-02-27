defmodule HajWeb.SettingsLive.Food.Show do
  use HajWeb, :live_view

  alias Haj.Foods

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:food, Foods.get_food!(id))}
  end

  defp page_title(:show), do: "Mat"
  defp page_title(:edit), do: "Redigera mat"
end
