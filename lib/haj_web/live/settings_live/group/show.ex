defmodule HajWeb.SettingsLive.Group.Show do
  use HajWeb, :live_view

  alias Haj.Repo
  alias Haj.Spex.ShowGroup
  alias Haj.Spex

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, stream(socket, :show_groups, Spex.get_show_groups_for_group(id))}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    {:noreply,
     socket
     |> assign(:group, Spex.get_group!(id))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_show_group, %{"show_group_id" => id}) do
    socket
    |> assign(:page_title, "Redigera spexgrupp")
    |> assign(:show_group, Spex.get_show_group!(id))
  end

  defp apply_action(socket, :new_show_group, _params) do
    socket
    |> assign(:page_title, "Ny spexgrupp")
    |> assign(:show_group, %ShowGroup{group_id: socket.assigns.group.id})
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Grupp")
    |> assign(:show_group, nil)
  end

  defp apply_action(socket, :edit, _params) do
    socket
    |> assign(:page_title, "Redigera grupp")
    |> assign(:show_group, nil)
  end

  defp group_name(group, show_group, live_action) do
    case live_action do
      :edit_show_group -> "#{group.name} #{show_group.show.year.year}"
      _ -> nil
    end
  end

  @impl true
  def handle_info(
        {HajWeb.SettingsLive.Group.ShowGroupFormComponent, {:saved, show_group}},
        socket
      ) do
    {:noreply, stream_insert(socket, :show_groups, show_group |> Repo.preload(:show))}
  end

  @impl true
  def handle_info({HajWeb.SettingsLive.Group.FormComponent, _}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_show_group", %{"id" => id}, socket) do
    show_group = Spex.get_show_group!(id)
    {:ok, _} = Spex.delete_show_group(show_group)

    {:noreply, stream_delete(socket, :show_groups, show_group)}
  end
end
