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
    conn
    |> render("groups.html")
  end

  def previous(conn, _params) do
    conn
    |> render("previous.html")
  end
end
