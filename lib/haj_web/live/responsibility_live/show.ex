defmodule HajWeb.ResponsibilityLive.Show do
  use HajWeb, :live_view

  alias Haj.Responsibilities

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    responsibility = Responsibilities.get_responsibility!(id)
    show = Haj.Spex.current_spex()

    shows =
      Haj.Spex.list_shows()
      |> Enum.map(fn %{id: id, year: year} -> [key: year.year, value: id] end)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:responsibility, responsibility)
      |> assign(:comments, Responsibilities.get_comments_for_show(responsibility, show.id))
      |> assign(
        :responsible_users,
        Responsibilities.get_all_responsible_users_for_responsibility(responsibility.id)
      )
      |> assign(:shows, shows)
      |> assign(:show, show)

    {:noreply, socket}
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
      class={"py-3 px-4 #{if @highligted?, do: "text-burgandy-500 border-b-2 border-burgandy-500", else: "text-gray-500"}"}
      navigate={@navigate}
    >
      <%= @text %>
    </.link>
    """
  end

  attr :class, :string, default: nil
  slot :left
  slot :right

  defp center_layout(assigns) do
    ~H"""
    <section class={["flex flex-row gap-4 justify-center relative w-full", @class]}>
      <div class="flex flex-col gap-4 mx-auto w-[48rem] max-w-full">
        <%= render_slot(@left) %>
      </div>
      <div class="hidden xl:flex flex-col sticky top-8 right-0 self-start w-64 px-6">
        <%= render_slot(@right) %>
      </div>
    </section>
    """
  end

  defp page_title(:show), do: "Ansvar"
  defp page_title(:comments), do: "Kommentarer"
  defp page_title(:history), do: "Historik"
  defp page_title(:edit), do: "Redigera ansvar"
end
