defmodule HajWeb.ApplyController do
  use HajWeb, :controller

  def index(conn, _params) do
    current_spex = Haj.Spex.current_spex()
    changeset = Haj.Applications.change_application(%Haj.Applications.Application{})

    case application_open?(current_spex) do
      true ->
        conn
        |> assign(:title, "Sök SpexM #{current_spex.year.year}")
        |> assign(:changeset, changeset)
        |> render("index.html")

      false ->
        conn |> assign(:title, "Ansökan stängd") |> render("closed.html")
    end
  end

  def created(conn, _params) do
    conn
    |> assign(:title, "Tack för ansökan")
    |> render("sucess.html")
  end

  defp application_open?(show) do
    current_date = DateTime.now!("Etc/UTC")

    case show.application_opens && DateTime.compare(show.application_opens, current_date) do
      :lt ->
        case DateTime.compare(show.application_closes, current_date) do
          :gt -> true
          _ -> false
        end

      _ ->
        false
    end
  end
end
