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
      |> assign(:shows, shows)
      |> assign(:show, show)

    {:noreply, socket}
  end

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

  defp page_title(:show), do: "Show Responsibility"
  defp page_title(:edit), do: "Edit Responsibility"
end
