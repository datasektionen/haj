defmodule HajWeb.DashboardLive.Unauthorized do
  use HajWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Tillgång nekad
      </.header>
      <div class="mt-2">
        Du har inte access till denna sida. Om du tror att det är fel, kontakta webbansvarig på
        <a href="mailto:webb@metaspexet.se" class="text-burgandy-600 font-bold">
          webb@metaspexet.se
        </a>
      </div>
    </div>
    """
  end
end
