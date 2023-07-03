defmodule HajWeb.ShowLive.Index do
  use HajWeb, :live_view

  alias Haj.Spex

  def mount(_params, _session, socket) do
    shows = Spex.list_shows()

    {:ok, assign(socket, page_title: "Alla spex", shows: shows)}
  end

  defp show_card(assigns) do
    ~H"""
    <.link
      navigate={~p"/shows/#{@show.id}"}
      class="flex flex-col gap-1 rounded-lg border px-4 py-4 hover:bg-gray-50 sm:gap-1.5"
    >
      <div class="text-burgandy-500 text-lg font-bold">
        <%= @show.title %>
      </div>
      <div :if={@show.or_title}>
        eller <%= @show.or_title %>
      </div>
      <div class="text-gray-500">
        METAspexet <%= @show.year.year %>
      </div>
    </.link>
    """
  end
end
