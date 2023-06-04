defmodule HajWeb.SettingsLive.Group.ShowGroupFormComponent do
  use HajWeb, :live_component

  alias Haj.Spex

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          <span :if={@name}>Redigerar <%= @name %>.</span>
          Detta är en specifik grupp för ett enskilt spex.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="show-group-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          :if={@action == :new}
          field={@form[:show_id]}
          type="select"
          label="Spex"
          options={@show_opions}
        />
        <.input
          field={@form[:application_description]}
          type="textarea"
          label="Beskrivning på ansökningssidan"
        />
        <.input
          field={@form[:application_extra_question]}
          type="textarea"
          label="Eventuell extra ansökningsfråga"
        />
        <.input field={@form[:application_open]} type="checkbox" label="Öppen för ansökan" />
        <:actions>
          <.button phx-disable-with="Sparar...">Spara spexgrupp</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{show_group: show_group, action: action} = assigns, socket) do
    changeset = Spex.change_show_group(show_group)

    shows =
      if action == :new do
        Spex.list_shows()
        |> Enum.map(fn show -> {"#{show.year.year}: #{show.title}", show.id} end)
      else
        []
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:show_opions, shows)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"show_group" => show_group_params}, socket) do
    changeset =
      socket.assigns.show_group
      |> Spex.change_show_group(show_group_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"show_group" => show_group_params}, socket) do
    save_show_group(socket, socket.assigns.action, show_group_params)
  end

  defp save_show_group(socket, :edit, show_group_params) do
    case Spex.update_show_group(socket.assigns.show_group, show_group_params) do
      {:ok, show_group} ->
        notify_parent({:saved, show_group})

        {:noreply,
         socket
         |> put_flash(:info, "Spexgrupp uppdaterades")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_show_group(socket, :new, show_group_params) do
    show_group_params = Map.put(show_group_params, "group_id", socket.assigns.show_group.group_id)

    case Spex.create_show_group(show_group_params) do
      {:ok, show_group} ->
        notify_parent({:saved, show_group})

        {:noreply,
         socket
         |> put_flash(:info, "Spexgrupp skapades")
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
