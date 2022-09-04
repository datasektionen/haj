defmodule HajWeb.GroupController do
  use HajWeb, :controller

  alias Haj.Spex

  def index(conn, _params) do
    current_show = Spex.current_spex()

    groups = Spex.get_show_groups_for_show(current_show.id)

    conn
    |> assign(:groups, groups)
    |> assign(:title, "Grupper")
    |> render("index.html")
  end

  def group(conn, %{"show_group_id" => id}) do

    show_group = Spex.get_show_group!(id)

    conn
    |> assign(:show_group, show_group)
    |> assign(:title, "#{show_group.group.name} #{show_group.show.year.year}")
    |> render("group.html")
  end
end
