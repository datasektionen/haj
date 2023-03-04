defmodule HajWeb.ResponsibilityLive.CommentEditor do
  use HajWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, clientside_rich_text: "")}
  end

  def update(%{comment: comment, action: action} = assigns, socket) do
    rich_text_id =
      case action do
        :edit -> "comment_richtext_editor"
        :new -> "new_comment_richtext_editor"
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(changeset: Haj.Responsibilities.change_comment(comment))
     |> assign(:clientside_rich_text, comment.text || "")
     |> assign(:rich_text_id, rich_text_id)
     |> push_event("set_richtext_data", %{richtext_data: comment.text || "", id: rich_text_id})}
  end

  def handle_event("validate_form", %{"comment" => params}, socket) do
    changeset = Haj.Responsibilities.change_comment(socket.assigns.comment, params)
    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("richtext_updated", %{"richtext_data" => richtext_data}, socket) do
    {:noreply,
     socket
     |> assign(:clientside_rich_text, richtext_data)
     |> push_event("richtext_event", %{richtext_data: richtext_data})}
  end

  def handle_event("save", %{"comment" => params}, socket) do
    save_comment(socket, socket.assigns.action, params)
  end

  defp save_comment(socket, :new, params) do
    params =
      params
      |> Map.put("user_id", socket.assigns.user.id)
      |> Map.put("responsibility_id", socket.assigns.responsibility.id)
      |> Map.put("show_id", socket.assigns.show.id)

    case Haj.Responsibilities.create_comment(params) do
      {:ok, _comment} ->
        send(self(), :comments_updated)

        {:noreply, socket |> push_event("set_richtext_data", %{richtext_data: ""})}

      {:error, changeset} ->
        push_flash(:error, "Error saving comment")

        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  defp save_comment(socket, :edit, params) do
    case Haj.Responsibilities.update_comment(socket.assigns.comment, params) do
      {:ok, _comment} ->
        send(self(), :comments_updated)

        {:noreply,
         socket
         |> push_event("set_richtext_data", %{richtext_data: ""})
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, changeset} ->
        push_flash(:error, "Error saving comment")

        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@changeset}
        phx-target={@myself}
        phx-change="validate_form"
        phx-submit="save"
        id="richtext_form"
        class="flex flex-col gap-4"
      >
        <div phx-hook="RichText" phx-update="ignore" phx-target={@myself} id={@rich_text_id}>
          <%= textarea(f, :text, value: @clientside_rich_text) %>
        </div>
        <%= error_tag(f, :text) %>
        <div class="flex justify-end">
          <.button phx-disable-with="Saving...">Spara</.button>
        </div>
      </.form>
    </div>
    """
  end
end
