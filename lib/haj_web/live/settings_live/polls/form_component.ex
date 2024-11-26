defmodule HajWeb.PollLive.FormComponent do
  use HajWeb, :live_component

  alias Haj.Polls

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage poll records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="poll-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:open]} type="checkbox" label="Open for voting" />
        <.input field={@form[:display_votes]} type="checkbox" label="Display votes" />
        <.input field={@form[:allow_user_options]} type="checkbox" label="Allow user options" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Poll</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{poll: poll} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Polls.change_poll(poll))
     end)}
  end

  @impl true
  def handle_event("validate", %{"poll" => poll_params}, socket) do
    changeset = Polls.change_poll(socket.assigns.poll, poll_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"poll" => poll_params}, socket) do
    save_poll(socket, socket.assigns.action, poll_params)
  end

  defp save_poll(socket, :edit, poll_params) do
    case Polls.update_poll(socket.assigns.poll, poll_params) do
      {:ok, poll} ->
        notify_parent({:saved, poll})

        {:noreply,
         socket
         |> put_flash(:info, "Poll updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_poll(socket, :new, poll_params) do
    case Polls.create_poll(poll_params) do
      {:ok, poll} ->
        notify_parent({:saved, poll})

        {:noreply,
         socket
         |> put_flash(:info, "Poll created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
