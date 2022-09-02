defmodule HajWeb.GroupController do
  use HajWeb, :controller

  def index(conn, %{"name" => group_name}) do
    group = Haj.Spex.get_group_by_name!(group_name)
    members = Haj.Spex.get_group_members(group.id)

    conn
    |> assign(:group, group)
    |> assign(:members, members)
    |> assign(:title, group_name)
    |> render("index.html")
  end
end
