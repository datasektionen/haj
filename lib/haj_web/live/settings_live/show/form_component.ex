defmodule HajWeb.SettingsLive.Show.FormComponent do
  use HajWeb, :live_component

  alias Haj.Spex

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Här kan du ändra på datan för ett spex.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="show-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Titel" />
        <.input field={@form[:or_title]} type="text" label="Eller-titel" />
        <.input field={@form[:description]} type="text" label="Beskrivning" />
        <.input field={@form[:year]} type="date" label="Datum/år" />
        <.input field={@form[:application_opens]} type="datetime-local" label="Ansökan öppnar" />
        <.input field={@form[:application_closes]} type="datetime-local" label="Ansökan stänger" />
        <.input field={@form[:slack_webhook_url]} type="text" label="Slack webhook url" />
        <:actions>
          <.button phx-disable-with="Sparar...">Spara spex</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{show: show} = assigns, socket) do
    changeset = Spex.change_show(show)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"show" => show_params}, socket) do
    changeset =
      socket.assigns.show
      |> Spex.change_show(show_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"show" => show_params}, socket) do
    save_show(socket, socket.assigns.action, show_params)
  end

  defp save_show(socket, :edit, show_params) do
    case Spex.update_show(socket.assigns.show, show_params) do
      {:ok, show} ->
        notify_parent({:saved, show})

        {:noreply,
         socket
         |> put_flash(:info, "Spex uppdaterades")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_show(socket, :new, show_params) do
    case Spex.create_show(show_params) do
      {:ok, show} ->
        notify_parent({:saved, show})

        {:noreply,
         socket
         |> put_flash(:info, "Spex skapades")
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
