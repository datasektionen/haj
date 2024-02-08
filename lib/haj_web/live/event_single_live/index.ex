defmodule HajWeb.EventSingleLive.Index do
  use HajWeb, :live_view

  alias Haj.Events

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_info({Events, _, _}, socket) do
    {:noreply, socket}
  end
end
