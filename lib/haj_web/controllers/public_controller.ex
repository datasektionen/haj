defmodule HajWeb.PublicController do
  use HajWeb, :controller

  def index(conn, _params) do
    card_content = Haj.Content.About.get_index_data()

    conn
    |> assign(:cards, card_content)
    |> assign(:page_title, "")
    |> render("index.html")
  end

  def spex(conn, _params) do
    shows = Haj.Content.About.get_shows()

    conn
    |> assign(:shows, shows)
    |> render("spexet.html")
  end

  def about(conn, _params) do
    conn
    |> render("about.html")
  end

  def groups(conn, _params) do
    all_groups = Haj.Content.Gropus.get_groups()

    conn
    |> assign(:groups, all_groups)
    |> render("groups.html")
  end

  def group(conn, %{"name" => name}) do
    group = Haj.Content.Gropus.get_group_by_name(name)

    case group do
      nil -> conn |> put_status(:not_found) |> put_view(HajWeb.ErrorView) |> render(:"404")
      group -> conn |> render("group.html", group: group)
    end
  end

  def previous(conn, _params) do
    all_spex = Haj.Content.About.get_previous_spex()
    conn
    |> assign(:spex, all_spex)
    |> render("previous.html")
  end

  def sok(conn, _params) do
    redirect(conn, external: haj_path(conn) <> "/sok")
  end

  defp haj_path(conn), do: "#{conn.scheme}://#{Application.get_env(:haj, :haj_subdomain)}.#{conn.host}:#{conn.port}"

end
