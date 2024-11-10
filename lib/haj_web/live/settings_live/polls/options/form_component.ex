defmodule HajWeb.OptionLive.FormComponent do
  use HajWeb, :live_component

  alias Haj.Polls

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage option records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="option-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:poll_id]} type="hidden" />
        <.input field={@form[:creator_id]} type="hidden" />

        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:url]} type="text" label="Url" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Option</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{option: option} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Polls.change_option(option))
     end)}
  end

  @impl true
  def handle_event("validate", %{"option" => option_params}, socket) do
    changeset = Polls.change_option(socket.assigns.option, option_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"option" => option_params}, socket) do
    save_option(socket, socket.assigns.action, option_params)
  end

  defp save_option(socket, :edit, option_params) do
    case Polls.update_option(socket.assigns.option, option_params) do
      {:ok, option} ->
        notify_parent({:saved, option})

        {:noreply,
         socket
         |> put_flash(:info, "Option updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_option(socket, :new, option_params) do
    case Polls.create_option(option_params) do
      {:ok, option} ->
        notify_parent({:saved, option})

        {:noreply,
         socket
         |> put_flash(:info, "Option created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
