defmodule HajWeb.SettingsLive.Group.Index do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Spex.Group

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :groups, Spex.list_groups())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Redigera grupp")
    |> assign(:group, Spex.get_group!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Ny grupp")
    |> assign(:group, %Group{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Grupper")
    |> assign(:group, nil)
  end

  @impl true
  def handle_info({HajWeb.SettingsLive.Group.FormComponent, {:saved, group}}, socket) do
    {:noreply, stream_insert(socket, :groups, group)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    group = Spex.get_group!(id)
    {:ok, _} = Spex.delete_group(group)

    {:noreply, stream_delete(socket, :groups, group)}
  end
end
