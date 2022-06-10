defmodule MetaspexetWeb.PageController do
  use MetaspexetWeb, :controller

  def index(conn, _params) do
    card_content = Metaspexet.Content.About.get_index_data()

    conn
    |> assign(:cards, card_content)
    |> render("index.html")
  end

  def spex(conn, _params) do
    shows = Metaspexet.Content.Spex.get_shows()

    conn
    |> assign(:shows, shows)
    |> render("spexet.html")
  end

  def about(conn, _params) do
    conn
    |> render("about.html")
  end

  def groups(conn, _params) do
    all_groups = Metaspexet.Content.Gropus.get_groups()

    conn
    |> assign(:groups, all_groups)
    |> render("groups.html")
  end

  def group(conn, %{"name" => name}) do
    group = Metaspexet.Content.Gropus.get_group_by_name(name)

    case group do
      nil -> conn |> put_status(:not_found) |> put_view(MetaspexetWeb.ErrorView) |> render(:"404")
      group -> conn |> render("group.html", group: group)
    end
  end

  def previous(conn, _params) do
    conn
    |> render("previous.html")
  end
end
