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

      <.simple_form for={@form} id="user-responsibility-form" phx-target={@myself} phx-submit="save">
        <.live_component
          id="search-component"
          module={HajWeb.Components.SearchComboboxComponent}
          search_fn={&Haj.Accounts.search_users/1}
          field={@form[:user_id]}
          label="Ansvarig"
        />

        <.input field={@form[:show_id]} type="select" label="Spex" options={@shows} />
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
