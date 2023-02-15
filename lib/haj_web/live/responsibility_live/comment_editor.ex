defmodule HajWeb.ResponsibilityLive.CommentEditor do
  use HajWeb, :live_component

  def mount(socket) do
    socket =
      socket
      |> assign(:changeset, Haj.Responsibilities.change_comment(%Haj.Responsibilities.Comment{}))
      |> assign(:clientside_rich_text, "")
      |> assign(:comment, %Haj.Responsibilities.Comment{})

    {:ok, socket}
  end

  def handle_event("validate_form", %{"comment" => params}, socket) do
    changeset = Haj.Responsibilities.change_comment(socket.assigns.comment, params)
    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"comment" => params}, socket) do
    params =
      params
      |> Map.put("text", params["content"])
      |> Map.put("user_id", socket.assigns.user.id)
      |> Map.put("responsibility_id", socket.assigns.responsibility.id)
      |> Map.put("show_id", socket.assigns.show.id)

    case Haj.Responsibilities.create_comment(params) do
      {:ok, _comment} ->
        send(self(), :comments_updated)

        {:noreply, socket |> push_event("richtext_event", %{richtext_data: ""})}

      {:error, changeset} ->
        push_flash(:error, "Error saving comment")

        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  def handle_event(
        "handle_clientside_richtext",
        %{"richtext_data" => richtext_data},
        socket
      ) do
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
        phx-change="validate_form"
        phx-submit="save"
        id="richtext_form"
        class="flex flex-col gap-4"
      >
        <div phx-hook="RichText" phx-update="ignore" phx-target={@myself} id="richtext_container">
          <%= textarea(f, :content, value: @clientside_rich_text) %>
        </div>
        <%= error_tag(f, :text) %>
        <div class="flex justify-end">
          <.button phx-disable-with="Saving...">Comment</.button>
        </div>
      </.form>
    </div>
    """
  end
end
