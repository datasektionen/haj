defmodule HajWeb.DashboardController do
  use HajWeb, :controller

  def index(conn, _params) do

    conn
    |> render("index.html")
  end

end
