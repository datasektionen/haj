defmodule HajWeb.ResponsibilityLive.FormComponent do
  use HajWeb, :live_component

  alias Haj.Responsibilities

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage responsibility records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="responsibility-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="name" />
        <.input field={{f, :description}} type="text" label="description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Responsibility</.button>
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
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"responsibility" => responsibility_params}, socket) do
    changeset =
      socket.assigns.responsibility
      |> Responsibilities.change_responsibility(responsibility_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"responsibility" => responsibility_params}, socket) do
    save_responsibility(socket, socket.assigns.action, responsibility_params)
  end

  defp save_responsibility(socket, :edit, responsibility_params) do
    case Responsibilities.update_responsibility(socket.assigns.responsibility, responsibility_params) do
      {:ok, _responsibility} ->
        {:noreply,
         socket
         |> put_flash(:info, "Responsibility updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_responsibility(socket, :new, responsibility_params) do
    case Responsibilities.create_responsibility(responsibility_params) do
      {:ok, _responsibility} ->
        {:noreply,
         socket
         |> put_flash(:info, "Responsibility created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
