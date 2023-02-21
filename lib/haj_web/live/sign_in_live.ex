defmodule HajWeb.SignInLive do
  use HajWeb, :live_view

  defp authorize_url(socket) do
    # scheme =
    #   case get_req_header(conn, "x-forwarded-proto") do
    #     [scheme] -> scheme
    #     [] -> conn.scheme
    #   end

    # port =
    #   case get_req_header(conn, "x-forwarded-port") do
    #     [port] -> port
    #     [] -> conn.port
    #   end

    ""
  end

  def render(assigns) do
    ~H"""
    <a href={Haj.Login.authorize_url()}>Logga in</a>
    """
  end
end
