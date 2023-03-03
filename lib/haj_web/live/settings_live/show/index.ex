defmodule HajWeb.SettingsLive.Show.Index do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Spex.Show

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :shows, Spex.list_shows())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Redigera spex")
    |> assign(:show, Spex.get_show!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nytt spex")
    |> assign(:show, %Show{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Alla spex")
    |> assign(:show, nil)
  end

  @impl true
  def handle_info({HajWeb.SettingsLive.Show.FormComponent, {:saved, show}}, socket) do
    {:noreply, stream_insert(socket, :shows, show)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    show = Spex.get_show!(id)
    {:ok, _} = Spex.delete_show(show)

    {:noreply, stream_delete(socket, :shows, show)}
  end
end
