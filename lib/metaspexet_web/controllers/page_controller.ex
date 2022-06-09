defmodule MetaspexetWeb.PageController do
  use MetaspexetWeb, :controller

  def index(conn, _params) do
    card_content = Metaspexet.Content.IndexPage.get_index_card_data()
    conn
    |> assign(:cards, card_content)
    |> render("index.html")
  end
end
