defmodule HajWeb.ResponsibilityLive.CommentEditor do
  use HajWeb, :live_component

  # Two second debounce of autosave
  @debounce 2_000

  @impl true
  def mount(socket) do
    {:ok, assign(socket, clientside_rich_text: "")}
  end

  @impl true
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
     |> assign(next_autosave: nil, saved: true)
     |> push_event("set_richtext_data", %{richtext_data: comment.text || "", id: rich_text_id})}
  end

  @impl true
  def update(%{event: :debounce, data: params}, socket) do
    # Handle debounce of save, here we autosave the responsibility
    case socket.assigns.action do
      :edit ->
        case Haj.Responsibilities.update_comment(socket.assigns.comment, params) do
          {:ok, comment} ->
            send(self(), {:comment_updated, comment})
            send(self(), :comments_updated)

            {:ok,
             assign(socket,
               comment: comment,
               saved: true,
               changeset: Haj.Responsibilities.change_comment(comment)
             )}

          {:error, changeset} ->
            push_flash(:error, "Error saving comment")

            {:ok, socket |> assign(:changeset, changeset)}
        end

      :new ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("richtext_updated", %{"richtext_data" => richtext_data}, socket) do
    # If empty, or when cleared, we have sometimes saved
    saved = if richtext_data == "", do: true, else: false
    send(self(), {:set_saved, saved})

    {:noreply,
     socket
     |> assign(clientside_rich_text: richtext_data, saved: saved)
     |> autosave_with_debounce(%{text: richtext_data})
     |> push_event("richtext_event", %{richtext_data: richtext_data})}
  end

  @impl true
  def handle_event("save", %{"comment" => params}, socket) do
    save_comment(socket, socket.assigns.action, params)
  end

  defp autosave_with_debounce(socket, params) do
    # This fires whenever the text changes
    timer =
      case socket.assigns.next_autosave do
        nil ->
          # No previous autosave, we send an message after @debounce time to save the data
          send_update_after(
            HajWeb.ResponsibilityLive.CommentEditor,
            [id: socket.assigns.id, event: :debounce, data: params],
            @debounce
          )

        timer ->
          # Data was changed before save, cancel previous message and send a new one
          Process.cancel_timer(timer)

          send_update_after(
            HajWeb.ResponsibilityLive.CommentEditor,
            [id: socket.assigns.id, event: :debounce, data: params],
            @debounce
          )
      end

    socket
    |> push_event("js-exec", %{
      to: "#updated_container",
      attr: "data-wait"
    })
    |> assign(next_autosave: timer)
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

        {:noreply,
         socket
         |> push_event("set_richtext_data", %{richtext_data: "", id: socket.assigns.rich_text_id})
         |> assign(saved: true)}

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
         |> assign(saved: true)
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, changeset} ->
        push_flash(:error, "Error saving comment")

        {:noreply, socket |> assign(:changeset, changeset)}
    end
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
        id="richtext_form"
        class="flex flex-col gap-4"
      >
        <div
          phx-hook="RichText"
          data-changed={"#{!@saved}"}
          phx-update="ignore"
          phx-target={@myself}
          id={@rich_text_id}
        >
          <%= textarea(f, :text) %>
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
