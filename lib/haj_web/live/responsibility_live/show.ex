defmodule HajWeb.ResponsibilityLive.Show do
  use HajWeb, :live_view

  alias Haj.Responsibilities
  alias Haj.Spex

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    responsibility = Responsibilities.get_responsibility!(id)

    socket =
      socket
      |> assign(:responsibility, responsibility)

    {:noreply, socket |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(page_title: "Ansvar")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(page_title: "Redigera ansvar")
  end

  defp apply_action(socket, :edit_comment, %{"comment_id" => comment_id}) do
    comment = Responsibilities.get_comment!(comment_id)
    show = Spex.get_show!(comment.show_id)

    shows =
      Spex.list_shows()
      |> Enum.map(fn %{id: id, year: year} -> [key: year.year, value: id] end)

    socket
    |> assign(page_title: "Redigera kommentar")
    |> assign(show: show)
    |> assign(
      comments: Responsibilities.get_comments_for_show(socket.assigns.responsibility, show.id)
    )
    |> assign(comment: comment)
    |> assign(shows: shows)
  end

  defp apply_action(socket, :comments, %{"show" => show_id}) do
    shows =
      Spex.list_shows()
      |> Enum.map(fn %{id: id, year: year} -> [key: year.year, value: id] end)

    show = Spex.get_show!(show_id)

    socket
    |> assign(page_title: "Kommentarer")
    |> assign(show: show)
    |> assign(
      comments: Responsibilities.get_comments_for_show(socket.assigns.responsibility, show.id)
    )
    |> assign(shows: shows)
  end

  defp apply_action(socket, :comments, %{"id" => _id}) do
    apply_action(socket, :comments, %{"show" => Spex.current_spex().id})
  end

  defp apply_action(socket, :history, _params) do
    socket
    |> assign(page_title: "Historik")
    |> assign(
      :responsible_users,
      Responsibilities.get_all_responsible_users_for_responsibility(
        socket.assigns.responsibility.id
      )
    )
  end

  @impl true
  def handle_event("select_show", %{"comments_form" => %{"show" => show_id}}, socket) do
    show = Haj.Spex.get_show!(show_id)

    {:noreply,
     socket
     |> assign(:show, show)
     |> assign(
       :comments,
       Responsibilities.get_comments_for_show(socket.assigns.responsibility, show.id)
     )}
  end

  @impl true
  def handle_event("select_tab", %{"tab_form" => %{"tab" => tab}}, socket) do
    {:noreply,
     socket |> push_patch(to: ~p"/live/responsibilities/#{socket.assigns.responsibility}/#{tab}")}
  end

  @impl true
  def handle_event("delete_comment", %{"id" => id}, socket) do
    comment = Responsibilities.get_comment!(id)

    {:ok, _} = Responsibilities.delete_comment(comment)

    comments =
      Responsibilities.get_comments_for_show(
        socket.assigns.responsibility,
        socket.assigns.show.id
      )

    {:noreply, assign(socket, comments: comments)}
  end

  @impl true
  def handle_info(:comments_updated, socket) do
    {:noreply,
     assign(
       socket,
       :comments,
       Responsibilities.get_comments_for_show(
         socket.assigns.responsibility,
         socket.assigns.show.id
       )
     )}
  end

  defp tab_link(assigns) do
    ~H"""
    <.link
      class={"#{if @highligted?, do: "text-burgandy-500 border-b-2 border-burgandy-500", else: "text-gray-500"} px-4 py-3"}
      navigate={@navigate}
    >
      <%= @text %>
    </.link>
    """
  end

  attr :class, :string, default: nil
  slot :left
  slot :right, default: nil

  defp center_layout(assigns) do
    ~H"""
    <section class={[
      "flex flex-row md:max-w-3xl xl:max-w-5xl gap-4 justify-center relative mx-auto",
      @class
    ]}>
      <div class="min-w-0 flex-grow">
        <%= render_slot(@left) %>
      </div>
      <div
        :if={@right != []}
        class="sticky top-8 right-0 ml-4 hidden w-full shrink-0 grow-0 basis-64 flex-col self-start px-6 xl:flex"
      >
        <%= render_slot(@right) %>
      </div>
    </section>
    """
  end
end
