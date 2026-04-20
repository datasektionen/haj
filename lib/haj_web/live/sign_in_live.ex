defmodule HajWeb.SignInLive do
  use HajWeb, :live_view

  def render(assigns) do
    ~H"""
    <a href={~p"/login"}>Logga in</a>
    """
  end
end
