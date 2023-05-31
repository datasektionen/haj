defmodule HajWeb.GroupAdminLive do
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

  def render(assigns) do
    ~H"""
    <h1 class="mt-4 text-3xl font-bold">
      Redigera <span class="text-burgandy-600"><%= @page_title %></span>
    </h1>
    <.form :let={f} for={@changeset} phx-submit="save" class="flex flex-col pb-2">
      <%= label(f, :application_description, "Beskrivning av gruppen",
        class: "mt-4 font-medium text-zinc-600"
      ) %>
      <%= textarea(f, :application_description,
        class: "border-1 mb-2 rounded-lg border-zinc-300 bg-zinc-50"
      ) %>

      <%= label(
        f,
        :application_extra_question,
        "Extra fråga i ansökan. Om du lämnar detta blankt kommer ingen extra fråga visas.",
        class: "mt-2 font-medium text-zinc-600"
      ) %>
      <%= textarea(f, :application_extra_question,
        class: "border-1 mb-2 rounded-lg border-zinc-300 bg-zinc-50"
      ) %>

      <div class="mb-2 flex items-center gap-2">
        <%= checkbox(f, :application_open) %>
        <%= label(f, :application_open, "Gruppen går att söka") %>
      </div>

      <%= submit("Spara",
        class: "bg-burgandy-500 self-start rounded-md px-16 py-2 text-white hover:bg-burgandy-400"
      ) %>
    </.form>
    <h2 class="text-burgandy-500 mt-6 font-bold uppercase">Lägg till medlemmar</h2>
    <p class="font-regular py-2 text-zinc-600">
      Välj vilken typ av medlem (chef/gruppis), sök på användare och lägg sedan till!
    </p>
    <div class="flex flex-row items-stretch gap-2">
      <.form :let={f} for={%{}} as={:role_form} phx-change="update_role">
        <%= select(f, :role, @roles, class: "h-full rounded-md border-zinc-400", value: @role) %>
      </.form>

      <.form
        :let={f}
        for={%{}}
        as={:search_form}
        phx-change="suggest"
        phx-submit="add_first_user"
        autocomplete={:off}
        class="flex-grow"
      >
        <%= text_input(f, :q, value: @query, class: "w-full rounded-md border-zinc-400") %>
      </.form>
    </div>

    <ol id="matches" class="mt-2 flex flex-col rounded-md bg-slate-100">
      <li :for={{user, i} <- Enum.with_index(@matches)}>
        <%= if i == 0 do %>
          <button
            value={user.id}
            class="w-full cursor-pointer px-3 py-2 text-left text-black opacity-50 hover:opacity-100"
            phx-click="add_user"
            phx-value-id={user.id}
          >
            <%= "#{user.first_name} #{user.last_name}" %>
          </button>
        <% else %>
          <button
            value={user.id}
            class="w-full cursor-pointer border-t px-3 py-2 text-left text-black opacity-50 hover:opacity-100"
            phx-click="add_user"
            phx-value-id={user.id}
          >
            <%= "#{user.first_name} #{user.last_name}" %>
          </button>
        <% end %>
      </li>
    </ol>
    <h3 class="mb-[-8px] mt-4 ml-2 text-sm font-semibold uppercase">Medlemmar</h3>
    <.table id="members-table" rows={@streams.members}>
      <:col :let={{_id, member}} label="Namn">
        <.user_card user={member.user} />
      </:col>
      <:col :let={{_id, member}} label="Mail">
        <%= member.user.email %>
      </:col>
      <:col :let={{_id, member}} label="Roll">
        <p
          :if={member.role == :chef}
          class="bg-burgandy-50 text-burgandy-400 inline-block rounded-md px-1"
        >
          Chef
        </p>

        <p :if={member.role == :gruppis}>
          Gruppis
        </p>
      </:col>
      <:action :let={{id, member}}>
        <button
          class="bg-burgandy-500 rounded-md px-2 py-0.5 text-white hover:bg-burgandy-400"
          phx-click={JS.push("remove_user", value: %{id: member.id}) |> hide("##{id}")}
        >
          Ta bort
        </button>
      </:action>
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
