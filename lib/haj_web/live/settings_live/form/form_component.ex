defmodule HajWeb.SettingsLive.Form.FormComponent do
  use HajWeb, :live_component

  alias Haj.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage form records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@client_form}
        id="form-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@client_form[:name]} type="text" label="Name" />
        <.input field={@client_form[:description]} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Form</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{form: form} = assigns, socket) do
    changeset = Forms.change_form(form)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"form" => form_params}, socket) do
    changeset =
      socket.assigns.form
      |> Forms.change_form(form_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"form" => form_params}, socket) do
    save_form(socket, socket.assigns.action, form_params)
  end

  defp save_form(socket, :edit, form_params) do
    case Forms.update_form(socket.assigns.form, form_params) do
      {:ok, form} ->
        notify_parent({:saved, form})

        {:noreply,
         socket
         |> put_flash(:info, "Form updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_form(socket, :new, form_params) do
    case Forms.create_form(form_params) do
      {:ok, form} ->
        notify_parent({:saved, form})

        {:noreply,
         socket
         |> put_flash(:info, "Form created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :client_form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
