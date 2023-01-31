defmodule HajWeb.ResponsibilityLive.Show do
  use HajWeb, :live_view

  alias Haj.Responsibilities

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:responsibility, Responsibilities.get_responsibility!(id))}
  end

  defp page_title(:show), do: "Show Responsibility"
  defp page_title(:edit), do: "Edit Responsibility"
end
