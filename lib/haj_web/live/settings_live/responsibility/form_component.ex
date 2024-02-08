defmodule HajWeb.SettingsLive.Responsibility.FormComponent do
  use HajWeb, :live_component

  alias Haj.Responsibilities

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Ändra datan kring ett ansvar i databasen..</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="responsibility-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <:actions>
          <.button phx-disable-with="Sparar...">Spara ansvar</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{responsibility: responsibility} = assigns, socket) do
    changeset = Responsibilities.change_responsibility(responsibility)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"responsibility" => responsibility_params}, socket) do
    changeset =
      socket.assigns.responsibility
      |> Responsibilities.change_responsibility(responsibility_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"responsibility" => responsibility_params}, socket) do
    save_responsibility(socket, socket.assigns.action, responsibility_params)
  end

  defp save_responsibility(socket, :edit, responsibility_params) do
    case Responsibilities.update_responsibility(
           socket.assigns.responsibility,
           responsibility_params
         ) do
      {:ok, responsibility} ->
        notify_parent({:saved, responsibility})

        {:noreply,
         socket
         |> put_flash(:info, "Ansvar uppdaterades")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_responsibility(socket, :new, responsibility_params) do
    case Responsibilities.create_responsibility(responsibility_params) do
      {:ok, responsibility} ->
        notify_parent({:saved, responsibility})

        {:noreply,
         socket
         |> put_flash(:info, "Ansvar skapades")
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
