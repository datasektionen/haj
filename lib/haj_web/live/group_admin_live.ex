defmodule HajWeb.GroupAdminLive do
  use HajWeb, :live_view

  alias Haj.Spex

  def mount(%{"show_group_id" => show_group_id}, _session, socket) do
    show_group = Spex.get_show_group!(show_group_id)
    changeset = Spex.change_show_group(show_group)
    user = socket.assigns[:current_user]
    IO.inspect(show_group)

    case is_admin?(socket, show_group) do
      true ->
        socket =
          socket
          |> assign(
            :show_group,
            show_group
          )
          |> assign(
            current_user: user,
            changeset: changeset,
            group: show_group,
            page_title: show_group.group.name,
            query: nil,
            loading: false,
            matches: [],
            roles: [:gruppis, :chef],
            role: :gruppis
          )

        {:ok, socket}

      false ->
        # Redirect to normal group page
        {:ok, redirect(socket, to: Routes.group_path(socket, :group, show_group.id))}
    end
  end

  def handle_event("suggest", %{"search_form" => %{"q" => query}}, socket) do
    users = Haj.Accounts.search_users(query)

    {:noreply, assign(socket, matches: users)}
  end

  def handle_event("update_role", %{"role_form" => %{"role" => role}}, socket) do
    {:noreply, assign(socket, role: role)}
  end

  def handle_event("add", _, %{assigns: %{matches: []}} = socket) do
    {:noreply, socket}
  end

  def handle_event("add", _, %{assigns: %{matches: [user | _]}} = socket) do
    add_user(user.id, socket.assigns.show_group.id, socket.assigns.role)

    updated = Haj.Spex.get_show_group!(socket.assigns.show_group.id)

    {:noreply, socket |> assign(show_group: updated, matches: [], query: nil)}
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

    updated = Haj.Spex.get_show_group!(socket.assigns.show_group.id)
    {:noreply, assign(socket, show_group: updated)}
  end

  def handle_event("add_user", %{"user" => id}, socket) do
    memberships = socket.assigns.show_group.group_memberships

    if Enum.any?(memberships, fn %{user_id: user_id} -> user_id == id |> String.to_integer() end) do
      {:noreply,
       socket
       |> assign(matches: [], query: nil)
       |> put_flash(:error, "Personen är redan medlem i gruppen.")}
    else
      add_user(id, socket.assigns.show_group.id, socket.assigns.role)
      updated = Haj.Spex.get_show_group!(socket.assigns.show_group.id)

      {:noreply, socket |> assign(show_group: updated, matches: [], query: nil)}
    end
  end

  defp add_user(user_id, show_group_id, role) do
    {:ok, _} =
      Haj.Spex.create_group_membership(%{
        user_id: user_id,
        show_group_id: show_group_id,
        role: role
      })
  end

  def render(assigns) do
    ~H"""
    <h1 class="mt-4 text-2xl font-regular">
      Redigera <span class="font-bold"><%= @page_title %></span>
    </h1>
    <.form :let={f} for={@changeset} phx-submit="save" class="flex flex-col pb-2">
      <%= label(f, :application_description, "Beskrivning av gruppen",
        class: "text-zinc-600 mt-4 font-medium"
      ) %>
      <%= textarea(f, :application_description,
        class: "mb-2 rounded-lg border-1 border-zinc-300 bg-zinc-50"
      ) %>

      <%= label(
        f,
        :application_extra_question,
        "Extra fråga i ansökan. Om du lämnar detta blankt kommer ingen extra fråga visas.",
        class: "text-zinc-600 mt-2 font-medium"
      ) %>
      <%= textarea(f, :application_extra_question,
        class: "mb-2 rounded-lg border-1 border-zinc-300 bg-zinc-50"
      ) %>

      <div class="mb-2 flex items-center gap-2">
        <%= checkbox(f, :application_open) %>
        <%= label(f, :application_open, "Gruppen går att söka") %>
      </div>

      <%= submit("Spara", class: "self-start bg-burgandy-500 px-8 py-2 rounded-md text-white") %>
    </.form>
    <h2 class="uppercase mt-6 font-bold text-burgandy-500">Lägg till medlemmar</h2>
    <p class="py-2 text-zinc-600 font-regular">
      Välj vilken typ av medlem (chef/gruppis), sök på användare och lägg sedan till!
    </p>
    <div class="flex flex-row items-stretch gap-2">
      <.form :let={f} for={:role_form} phx-change="update_role">
        <%= select(f, :role, @roles, class: "h-full rounded-md border-zinc-400", value: @role) %>
      </.form>

      <.form
        :let={f}
        for={:search_form}
        phx-change="suggest"
        phx-submit="add"
        autocomplete={:off}
        class="flex-grow"
      >
        <%= text_input(f, :q, value: @query, class: "w-full rounded-md border-zinc-400") %>
      </.form>
    </div>

    <div id="matches" class="flex flex-col bg-white mt-2">
      <%= for {user, i} <- Enum.with_index(@matches) do %>
        <%= if i == 0 do %>
          <div
            value={user.id}
            class="px-3 py-2 bg-orange text-gray-100 hover:bg-orange/80"
            phx-click="add_user"
            phx-value-user={user.id}
          >
            <%= "#{user.first_name} #{user.last_name}" %>
          </div>
        <% else %>
          <div
            value={user.id}
            class="px-3 py-2 hover:bg-gray-200"
            phx-click="add_user"
            phx-value-user={user.id}
          >
            <%= "#{user.first_name} #{user.last_name}" %>
          </div>
        <% end %>
      <% end %>
    </div>

    <div class="uppercase font-bold py-2">Nuvarande medlemmar</div>

    <.table id="chef-table" rows={@show_group.group_memberships |> Enum.filter(&(&1.role == :chef))}>
      <:col :let={member} label="Chefer">
        <div class="flex flex-row justify-between">
          <%= "#{member.user.first_name} #{member.user.last_name}" %>
          <button
            class="bg-orange text-white px-2 py-0.5 rounded-sm"
            phx-click="remove_user"
            phx-value-id={member.id}
          >
            Ta bort
          </button>
        </div>
      </:col>
    </.table>

    <.table
      id="gruppis-table"
      rows={@show_group.group_memberships |> Enum.filter(&(&1.role == :gruppis))}
    >
      <:col :let={member} label="Gruppisar">
        <div class="flex flex-row justify-between">
          <%= "#{member.user.first_name} #{member.user.last_name}" %>
          <button
            class="bg-orange text-white px-2 py-0.5 rounded-sm"
            phx-click="remove_user"
            phx-value-id={member.id}
          >
            Ta bort
          </button>
        </div>
      </:col>
    </.table>
    """
  end

  defp is_admin?(socket, show_group) do
    socket.assigns.current_user.role == :admin ||
      show_group.group_memberships
      |> Enum.any?(fn %{user_id: id, role: role} ->
        role == :chef && id == socket.assigns.current_user.id
      end)
  end
end
