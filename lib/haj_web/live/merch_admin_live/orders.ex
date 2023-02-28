defmodule HajWeb.MerchAdminLive.Orders do
  use HajWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    Beställningar
    """
  end
end
