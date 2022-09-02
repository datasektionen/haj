defmodule HajWeb.UserController do
  use HajWeb, :controller

  def index(conn, %{"username" => username}) do
    user = Haj.Accounts.get_user_by_username!(username)

    conn
    |> assign(:user, user)
    |> assign(:title, "#{user.first_name} #{user.last_name}")
    |> render("index.html")
  end

  def groups(conn, %{"username" => username}) do
    user = Haj.Accounts.get_user_by_username!(username)
    groups = Haj.Spex.get_user_groups(user.id)

    groups_by_year = Enum.reduce(groups, %{}, fn %{group: g, year: y}, acc ->
      Map.update(acc, y, [g], fn gs -> [g | gs] end)
    end)

    conn
    |> assign(:user, user)
    |> assign(:groups, groups_by_year)
    |> assign(:title, "#{user.first_name} #{user.last_name}: grupper")
    |> render("groups.html")
  end
end
