defmodule HajWeb.GroupLive.Admin do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Repo

  def mount(%{"show_group_id" => show_group_id}, _session, socket) do
    show_group = Spex.get_show_group!(show_group_id)
    changeset = Spex.change_show_group(show_group)

    if is_admin?(socket, show_group) do
      {:ok,
       socket
       |> stream(
         :members,
         show_group.group_memberships
         |> Enum.sort_by(fn %{role: role} -> role end)
       )
       |> assign(
         changeset: changeset,
         show_group: show_group,
         page_title: show_group.group.name,
         query: nil,
         matches: [],
         roles: [:gruppis, :chef],
         role: :gruppis
       )}
    else
      # Redirect to normal group page
      {:ok, redirect(socket, to: ~p"/live/group/#{show_group}")}
    end
  end

  def handle_event("suggest", %{"search_form" => %{"q" => query}}, socket) do
    users = Haj.Accounts.search_users(query)

    {:noreply, assign(socket, matches: users, query: query)}
  end

  def handle_event("update_role", %{"role_form" => %{"role" => role}}, socket) do
    {:noreply, assign(socket, role: role)}
  end

  def handle_event("add_first_user", _, %{assigns: %{matches: []}} = socket) do
    {:noreply, socket}
  end

  def handle_event("add_first_user", _, %{assigns: %{matches: [user | _]}} = socket) do
    add_user(user.id, socket)
  end

  def handle_event("add_user", %{"id" => id}, socket) do
    add_user(String.to_integer(id), socket)
  end

  def handle_event("save", %{"show_group" => show_group}, socket) do
    case Spex.update_show_group(socket.assigns.show_group, show_group) do
      {:ok, show_group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Sparat.")
         |> assign(changeset: Spex.change_show_group(show_group))}

      {:error, changeset} ->
        {:noreply, socket |> put_flash(:error, "Något gick fel.") |> assign(changeset: changeset)}
    end
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    membership = Haj.Spex.get_group_membership!(id)
    {:ok, _} = Haj.Spex.delete_group_membership(membership)
    {:noreply, stream_delete(socket, :members, membership)}
  end

  @spec add_user(any, Phoenix.LiveView.Socket.t()) :: {:noreply, any}
  def add_user(id, socket) do
    case Haj.Spex.is_member_of_show_group?(id, socket.assigns.show_group.id) do
      true ->
        {:noreply,
         socket |> put_flash(:error, "Användaren är redan med i gruppen.") |> assign(matches: [])}

      false ->
        {:ok, member} =
          Haj.Spex.create_group_membership(%{
            user_id: id,
            show_group_id: socket.assigns.show_group.id,
            role: socket.assigns.role
          })

        member = Repo.preload(member, :user)

        if member.role == :chef do
          {:noreply, stream_insert(socket, :members, member, at: 0) |> assign(matches: [])}
        else
          {:noreply, stream_insert(socket, :members, member, at: -1) |> assign(matches: [])}
        end
    end
  end

  defp is_admin?(socket, show_group) do
    socket.assigns.current_user.role == :admin ||
      show_group.group_memberships
      |> Enum.any?(fn %{user_id: id, role: role} ->
        role == :chef && id == socket.assigns.current_user.id
      end)
  end
end
