defmodule HajWeb.GoogleTestLive do
  use HajWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <button id="authorize_button" phx-hook="AuthorizeGoogle">Authorize</button>
    <button id="signout_button" onclick="handleSignoutClick()">Sign Out</button>
    """
  end
end
