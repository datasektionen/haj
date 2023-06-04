defmodule HajWeb.SettingsLive.User.FormComponent do
  use HajWeb, :live_component

  alias Haj.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Här kan du ändra på datan för en användare.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="show-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:first_name]} type="text" label="Förnamn" />
        <.input field={@form[:last_name]} type="text" label="Efternamn" />
        <.input field={@form[:username]} type="text" label="KTH-id" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:google_account]} type="text" label="Google-konto" />
        <.input field={@form[:phone]} type="text" label="Telefonnummer" />
        <.input field={@form[:class]} type="text" label="Klass" />
        <.input field={@form[:personal_number]} type="text" label="Personnr" />

        <.input field={@form[:street]} type="text" label="Adress" />
        <.input field={@form[:zip]} type="text" label="Postkod" />
        <.input field={@form[:city]} type="text" label="Stad" />

        <.input field={@form[:role]} type="select" label="Roll" options={@roles} />

        <:actions>
          <.button phx-disable-with="Sparar...">Spara spex</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Användare uppdaterades")
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
