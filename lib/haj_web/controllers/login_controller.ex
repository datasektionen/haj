defmodule HajWeb.LoginController do
  use HajWeb, :controller

  def login(conn, _params) do

    if conn.assigns[:current_user] do
      conn |> redirect(to: Routes.dashboard_path(conn, :index))
    else
      conn |> render("login.html")
    end
  end
end
