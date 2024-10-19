defmodule HajWeb.GroupLive.Admin do
  use HajWeb, :live_view

  alias Haj.Spex
  alias Haj.Repo
  alias Haj.Policy

  def mount(%{"show_group_id" => show_group_id}, _session, socket) do
    show_group = Spex.get_show_group!(show_group_id)
    changeset = Spex.change_show_group(show_group)

    case Policy.authorize(:show_group_edit, socket.assigns.current_user, show_group) do
      :ok ->
        {:ok,
         socket
         |> stream(
           :members,
           show_group.group_memberships
           |> Enum.sort_by(fn %{role: role} -> role end)
         )
         |> assign(
           show_group: show_group,
           page_title: show_group.group.name,
           query: nil,
           matches: [],
           roles: [:gruppis, :chef],
           role: :gruppis
         )
         |> assign_form(changeset)}

      _ ->
        {:ok,
         socket
         |> put_flash(:error, "Du har inte behörighet att redigera denna grupp")
         |> redirect(to: ~p"/group/#{show_group}")}
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
         |> assign_form(Spex.change_show_group(show_group))}

      {:error, changeset} ->
        {:noreply, socket |> put_flash(:error, "Något gick fel.") |> assign_form(changeset)}
    end
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    membership = Haj.Spex.get_group_membership!(id)
    {:ok, _} = Haj.Spex.delete_group_membership(membership)
    {:noreply, stream_delete(socket, :members, membership)}
  end

  def add_user(id, socket) do
    if Haj.Spex.member_of_show_group?(id, socket.assigns.show_group.id) do
      {:noreply,
       socket |> put_flash(:error, "Användaren är redan med i gruppen.") |> assign(matches: [])}
    else
      {:ok, member} =
        Haj.Spex.create_group_membership(%{
          user_id: id,
          show_group_id: socket.assigns.show_group.id,
          role: socket.assigns.role
        })

      member = Repo.preload(member, :user)

      pos = if member.role == :chef, do: 0, else: -1

      {:noreply, stream_insert(socket, :members, member, at: pos) |> assign(matches: [])}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
  end
end
