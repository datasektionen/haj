defmodule HajWeb.SettingsLive.Food.FormComponent do
  use HajWeb, :live_component

  alias Haj.Foods

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Visas som alternativ för matpreferens för användare.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="food-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Namn" />
        <:actions>
          <.button phx-disable-with="Sparar...">Spara mat</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{food: food} = assigns, socket) do
    changeset = Foods.change_food(food)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"food" => food_params}, socket) do
    changeset =
      socket.assigns.food
      |> Foods.change_food(food_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"food" => food_params}, socket) do
    save_food(socket, socket.assigns.action, food_params)
  end

  defp save_food(socket, :edit, food_params) do
    case Foods.update_food(socket.assigns.food, food_params) do
      {:ok, food} ->
        notify_parent({:saved, food})

        {:noreply,
         socket
         |> put_flash(:info, "Mat uppdaterades")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_food(socket, :new, food_params) do
    case Foods.create_food(food_params) do
      {:ok, food} ->
        notify_parent({:saved, food})

        {:noreply,
         socket
         |> put_flash(:info, "Mat skapades")
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
