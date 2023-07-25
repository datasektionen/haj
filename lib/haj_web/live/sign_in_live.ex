defmodule HajWeb.SignInLive do
  use HajWeb, :live_view

  def render(assigns) do
    ~H"""
    <a href={Haj.Login.authorize_url()}>Logga in</a>
    """
  end
end
