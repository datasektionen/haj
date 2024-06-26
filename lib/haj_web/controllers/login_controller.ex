defmodule HajWeb.LoginController do
  use HajWeb, :controller

  def login(conn, _params) do
    if conn.assigns[:current_user] do
      conn |> redirect(to: ~p"/dashboard")
    else
      conn |> render("login.html")
    end
  end

  def unauthorized(conn, _params) do
    conn |> render("login.html")
  end
end
