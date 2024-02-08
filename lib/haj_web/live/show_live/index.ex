defmodule HajWeb.ShowLive.Index do
  use HajWeb, :live_view

  alias Haj.Spex

  def mount(_params, _session, socket) do
    shows = Spex.list_shows()

    {:ok, assign(socket, page_title: "Alla spex", shows: shows)}
  end
end
