defmodule HajWeb.ApplicationController do
  use HajWeb, :controller

  def index(conn, _params) do
    current_spex = Haj.Spex.current_spex()
    changeset = Haj.Applications.change_application(%Haj.Applications.Application{})

    conn
    |> assign(:title, "Sök spexet #{current_spex.year.year}")
    |> assign(:changeset, changeset)
    |> render("index.html")
  end
end
