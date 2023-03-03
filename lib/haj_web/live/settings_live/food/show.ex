defmodule HajWeb.SettingsLive.Food.Show do
  use HajWeb, :live_view

  alias Haj.Foods

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, stream(socket, :users, Foods.list_users_with_food_preference(id))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:food, Foods.get_food!(id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {1, _} = Foods.remove_food_preference_from_user(id, socket.assigns.food.id)

    {:noreply, stream_delete(socket, :users, %{id: id})}
  end

  defp page_title(:show), do: "Mat"
  defp page_title(:edit), do: "Redigera mat"
end
