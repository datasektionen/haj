defmodule HajWeb.MembersController do
  use HajWeb, :controller

  def index(conn, _params) do
    members = Haj.Spex.get_current_members()

    conn
    |> assign(:title, "Medlemmar")
    |> assign(:members, members)
    |> render("index.html")
  end
end
