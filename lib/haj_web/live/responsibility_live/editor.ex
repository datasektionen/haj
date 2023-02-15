defmodule HajWeb.ResponsibilityLive.Editor do
  use HajWeb, :live_component
  alias Haj.Responsibilities

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{responsibility: responsibility} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:changeset, Responsibilities.change_responsibility(responsibility))
      |> assign(:clientside_rich_text, responsibility.description)
      |> push_event("set_richtext_data", %{richtext_data: responsibility.description})

    {:ok, socket}
  end

  def handle_event("validate_responsibility_form", %{"responsibility" => params}, socket) do
    changeset = Responsibilities.change_responsibility(socket.assigns.responsibility, params)
    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"responsibility" => params}, socket) do
    case Haj.Responsibilities.update_responsibility(socket.assigns.responsibility, params) do
      {:ok, _comment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Responsibility updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, changeset} ->
        push_flash(:error, "Error saving comment")

        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  def handle_event("richtext_updated", %{"richtext_data" => richtext_data}, socket) do
    {:noreply,
     socket
     |> assign(:clientside_rich_text, richtext_data)
     |> push_event("richtext_event", %{richtext_data: richtext_data})}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@changeset}
        phx-target={@myself}
        phx-change="validate_responsibility_form"
        phx-submit="save"
        id="richtext_form"
        class="flex flex-col gap-4"
      >
        <div phx-hook="RichText" phx-update="ignore" phx-target={@myself} id="comment_richtext">
          <%= textarea(f, :description, value: @clientside_rich_text) %>
        </div>
        <%= error_tag(f, :description) %>
        <div class="flex justify-end">
          <.button phx-disable-with="Saving...">Spara</.button>
        </div>
      </.form>
    </div>
    """
  end
end
