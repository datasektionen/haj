defmodule HajWeb.SettingsController do
  use HajWeb, :controller

  def index(conn, _params) do
    conn |> assign(:title, "Administrera") |> render("index.html")
  end

  plug :authorize

  defp authorize(conn, _) do
    if conn.assigns.current_user.role == :admin do
      current_spex = Haj.Spex.current_spex()
      conn |> assign(:spex, current_spex)
    else
      conn
      |> put_flash(:error, "Du har inte tillgång till denna sida.")
      |> redirect(to: Routes.dashboard_path(conn, :index))
      |> halt()
    end
  end
end
