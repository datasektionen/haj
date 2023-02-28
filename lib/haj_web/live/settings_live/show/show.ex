defmodule HajWeb.SettingsLive.Show.Show do
  use HajWeb, :live_view

  alias Haj.Repo
  alias Haj.Spex

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, stream(socket, :show_groups, Spex.get_show_groups_for_show(id))}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    show_groups = Haj.Spex.get_show_groups_for_show(id)

    options =
      Spex.list_groups()
      |> Enum.filter(fn %{id: id} ->
        !Enum.any?(show_groups, fn %{group: %{id: g_id}} -> g_id == id end)
      end)
      |> Enum.map(fn g -> {g.name, g.id} end)

    changeset = Haj.Spex.change_show_group(%Haj.Spex.ShowGroup{show_id: id})

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(show: Spex.get_show!(id), groups: options, form: to_form(changeset))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_show_group, %{"show_group_id" => id}) do
    socket
    |> assign(:show_group, Spex.get_show_group!(id))
  end

  defp apply_action(socket, _, _), do: socket

  @impl true
  def handle_event("add_show_group", %{"show_group" => show_group_params}, socket) do
    show_group_params = Map.put(show_group_params, "show_id", socket.assigns.show.id)

    case Haj.Spex.create_show_group(show_group_params) do
      {:ok, show_group} ->
        show_group = Repo.preload(show_group, :group)
        options = Enum.reject(socket.assigns.groups, fn {_, id} -> id == show_group.group.id end)

        {:noreply,
         put_flash(socket, :info, "Grupp lades till")
         |> stream_insert(:show_groups, show_group)
         |> assign(groups: options)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete_show_group", %{"id" => id}, socket) do
    show_group = Spex.get_show_group!(id)
    {:ok, _} = Spex.delete_show_group(show_group)

    {:noreply, stream_delete(socket, :show_groups, show_group)}
  end

  defp page_title(:show), do: "Visa spex"
  defp page_title(:edit), do: "Redigera spex"
  defp page_title(:edit_show_group), do: "Redigera spexgrupp"
end
