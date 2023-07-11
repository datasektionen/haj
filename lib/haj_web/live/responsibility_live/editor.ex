defmodule HajWeb.ResponsibilityLive.Editor do
  use HajWeb, :live_component
  alias Haj.Responsibilities

  # 2 second debounce for autosave
  @debounce 2_000

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{responsibility: responsibility} = assigns, socket) do
    socket =
      assign(socket, assigns)
      |> assign(:changeset, Responsibilities.change_responsibility(responsibility))
      |> assign(:clientside_rich_text, responsibility.description)
      |> assign(next_autosave: nil, saved: true)
      |> push_event("set_richtext_data", %{richtext_data: responsibility.description})

    {:ok, socket}
  end

  @impl true
  def update(%{event: :debounce, data: params}, socket) do
    # Handle debounce of save, here we autosave the responsibility
    case Haj.Responsibilities.update_responsibility(socket.assigns.responsibility, params) do
      {:ok, responsibility} ->
        Process.send(self(), {:responsibility_updated, responsibility}, [])

        {:ok,
         assign(socket, responsibility: responsibility, saved: true)
         |> assign(:changeset, Responsibilities.change_responsibility(responsibility))}

      {:error, changeset} ->
        push_flash(:error, "Error autosaving saving comment")

        {:ok, socket |> assign(:changeset, changeset)}
    end
  end

  @impl true
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

  @impl true
  def handle_event("validate", %{"responsibility" => params}, socket) do
    # This fires whenever the text changes
    timer =
      case socket.assigns.next_autosave do
        nil ->
          # No previous autosave, we send an message after @debounce time to save the data
          send_update_after(
            HajWeb.ResponsibilityLive.Editor,
            [id: socket.assigns.id, event: :debounce, data: params],
            @debounce
          )

        timer ->
          # Data was changed before save, cancel previous message and send a new one
          Process.cancel_timer(timer)

          send_update_after(
            HajWeb.ResponsibilityLive.Editor,
            [id: socket.assigns.id, event: :debounce, data: params],
            @debounce
          )
      end

    {:noreply,
     push_event(socket, "js-exec", %{
       to: "#updated_container",
       attr: "data-wait"
     })
     |> assign(next_autosave: timer)}
  end

  def handle_event("richtext_updated", %{"richtext_data" => richtext_data}, socket) do
    send(self(), {:set_saved, false})

    {:noreply,
     socket
     |> assign(clientside_rich_text: richtext_data, saved: false)
     |> push_event("richtext_event", %{richtext_data: richtext_data})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@changeset}
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate"
        id="richtext_form"
        class="flex flex-col gap-4"
      >
        <div
          phx-hook="RichText"
          data-changed={"#{!@saved}"}
          phx-update="ignore"
          phx-target={@myself}
          id={"comment_richtext_#{@responsibility.id}"}
        >
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
