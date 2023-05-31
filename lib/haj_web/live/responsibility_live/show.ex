defmodule HajWeb.ResponsibilityLive.Show do
  use HajWeb, :live_view

  alias Haj.Responsibilities
  alias Haj.Spex
  alias Haj.Policy

  on_mount {HajWeb.UserAuth, {:authorize, :responsibility_read}}

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

  defp apply_action(socket, :show, %{"id" => _id}) do
    socket
    |> assign(page_title: "Ansvar")
  end

  defp apply_action(socket, :edit, %{"id" => _id}) do
    %{current_user: user, responsibility: responsibility} = socket.assigns

    case Policy.authorize(:responsibility_edit, user, responsibility) do
      :ok ->
        socket
        |> assign(page_title: "Redigera ansvar")

      _ ->
        socket
        |> redirect_unathorized(~p"/responsibilities/#{responsibility}")
    end
  end

  defp apply_action(socket, :edit_comment, %{"comment_id" => comment_id}) do
    %{current_user: user, responsibility: responsibility} = socket.assigns
    comment = Responsibilities.get_comment!(comment_id)

    case Policy.authorize(:responsibility_comment_edit, user, comment) do
      :ok ->
        show = Spex.get_show!(comment.show_id)

        shows =
          Spex.list_shows()
          |> Enum.map(fn %{id: id, year: year} -> [key: year.year, value: id] end)

        socket
        |> assign(page_title: "Redigera kommentar")
        |> assign(show: show)
        |> assign(comments: Responsibilities.get_comments_for_show(responsibility, show.id))
        |> assign(authorized: true)
        |> assign(comment: comment)
        |> assign(shows: shows)

      _ ->
        socket
        |> put_flash(:error, "Du har inte behörighet att redigera kommentaren")
        |> redirect_unathorized(
          ~p"/responsibilities/#{responsibility}/comments?show=#{comment.show_id}"
        )
    end
  end

  defp apply_action(socket, :comments, %{"show" => show_id}) do
    %{current_user: user, responsibility: responsibility} = socket.assigns

    shows =
      Spex.list_shows()
      |> Enum.map(fn %{id: id, year: year} -> [key: year.year, value: id] end)

    show = Spex.get_show!(show_id)

    authorized = Policy.authorize?(:responsibility_comment_create, user, responsibility)

    socket
    |> assign(page_title: "Testamenten")
    |> assign(show: show)
    |> assign(comments: Responsibilities.get_comments_for_show(responsibility, show.id))
    |> assign(authorized: authorized)
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
      Responsibilities.get_users_for_responsibility_grouped(socket.assigns.responsibility.id)
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
     socket |> push_patch(to: ~p"/responsibilities/#{socket.assigns.responsibility}/#{tab}")}
  end

  @impl true
  def handle_event("delete_comment", %{"id" => id}, socket) do
    %{current_user: user, responsibility: responsibility} = socket.assigns

    comment = Responsibilities.get_comment!(id)

    case Policy.authorize(:responsibility_comment_delete, user, comment) do
      :ok ->
        {:ok, _} = Responsibilities.delete_comment(comment)

        comments =
          Responsibilities.get_comments_for_show(
            responsibility,
            socket.assigns.show.id
          )

        {:noreply, assign(socket, comments: comments)}

      _ ->
        {:noreply, put_flash(socket, :error, "Du kan inte ta bort någon annans testamente!")}
    end
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

  defp redirect_unathorized(socket, navigate) do
    socket
    |> put_flash(:error, "Du är inte ansvarig för detta ansvar och kan inte ändra på det.")
    |> push_patch(to: navigate)
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
