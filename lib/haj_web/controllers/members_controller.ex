defmodule HajWeb.MembersController do
  use HajWeb, :controller

  def index(conn, _params) do
    show = Haj.Spex.current_spex()

    members = Haj.Spex.list_members_for_show(show.id)

    conn
    |> assign(:title, "Medlemmar")
    |> assign(:members, members)
    |> render("index.html")
  end
end
