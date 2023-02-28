defmodule HajWeb.SettingsLive.Food.Index do
  use HajWeb, :live_view

  alias Haj.Foods
  alias Haj.Foods.Food

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :foods, Foods.list_foods())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Redigera mat")
    |> assign(:food, Foods.get_food!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Ny mat")
    |> assign(:food, %Food{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Alla matpreferenser")
    |> assign(:food, nil)
  end

  @impl true
  def handle_info({HajWeb.SettingsLive.Food.FormComponent, {:saved, food}}, socket) do
    {:noreply, stream_insert(socket, :foods, food)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    food = Foods.get_food!(id)
    {:ok, _} = Foods.delete_food(food)

    {:noreply, stream_delete(socket, :foods, food)}
  end
end
