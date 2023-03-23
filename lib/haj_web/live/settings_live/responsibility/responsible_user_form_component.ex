defmodule HajWeb.SettingsLive.Responsibility.ResponsibleUserFormComponent do
  use HajWeb, :live_component

  alias Haj.Responsibilities
  alias Haj.Spex

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form for={} as={:search_form} phx-target={@myself} phx-change="search">
        <.input name="q" label="Sök efter användare" type="text" value={@query} autocomplete={:off} />
      </.simple_form>

      <div class="mt-2">
        <div
          :for={user <- @users}
          title="Namn"
          class="cursor-pointer rounded-md px-3 py-2 hover:bg-gray-100"
          phx-click="select_user"
          phx-value-id={user.id}
          phx-target={@myself}
        >
          <%= user.full_name %>
        </div>
      </div>

      <.simple_form
        for={@form}
        id="user-responsibility-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          name="username"
          label="Vald andvändare"
          type="text"
          disabled
          value={@user && @user.full_name}
        />

        <.input field={@form[:show_id]} type="select" label="Spex" options={@shows} />
        <.input field={@form[:user_id]} type="hidden" value={@user && @user.id} />
        <:actions>
          <.button phx-disable-with="Sparar...">Spara</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{responsible_user: responsible_user} = assigns, socket) do
    changeset = Responsibilities.change_responsible_user(responsible_user)

    shows =
      Spex.list_shows()
      |> Enum.map(fn show -> {"#{show.year.year}: #{show.title}", show.id} end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:shows, shows)
     |> assign(query: "", user: nil, users: [])
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"responsible_user" => params}, socket) do
    changeset =
      socket.assigns.responsible_user
      |> Responsibilities.change_responsible_user(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    users = Haj.Accounts.search_users(query) |> Enum.slice(0..5)

    {:noreply, assign(socket, users: users, query: query)}
  end

  @impl true
  def handle_event("select_user", %{"id" => user_id}, socket) do
    user = Haj.Accounts.get_user!(user_id)

    {:noreply, assign(socket, user: user, users: [], query: "")}
  end

  @impl true
  def handle_event("save", %{"responsible_user" => params}, socket) do
    save_responsible_user(socket, params)
  end

  defp save_responsible_user(socket, params) do
    params = Map.put(params, "responsibility_id", socket.assigns.responsibility.id)

    case Responsibilities.create_responsible_user(params) do
      {:ok, responsible_user} ->
        notify_parent({:saved, responsible_user})

        {:noreply,
         socket
         |> put_flash(:info, "Ansvar tilldelades")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
