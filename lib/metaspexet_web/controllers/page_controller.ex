defmodule MetaspexetWeb.PageController do
  use MetaspexetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
