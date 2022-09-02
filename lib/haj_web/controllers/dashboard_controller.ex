defmodule HajWeb.DashboardController do
  use HajWeb, :controller

  def index(conn, _params) do

    conn
    |> assign(:title, "Min Sida")
    |> render("index.html")
  end

  def get_data(conn, _params) do
    user = conn.assigns[:current_user]

    changeset = Haj.Accounts.change_user(user)

    conn
    |> assign(:title, "Dina uppgifter: #{user.first_name} #{user.last_name}")
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update_data(conn, %{"user" => change}) do
    user = conn.assigns[:current_user]

    {:ok, _} = Haj.Accounts.update_user(user, change)

    conn
  end

end
