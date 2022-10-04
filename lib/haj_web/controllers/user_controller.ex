defmodule HajWeb.UserController do
  use HajWeb, :controller

  def index(conn, %{"username" => username}) do
    user =
      Haj.Accounts.get_user_by_username!(username)
      |> Haj.Repo.preload(:foods)

    conn
    |> assign(:user, user)
    |> assign(:title, "#{user.first_name} #{user.last_name}")
    |> render("index.html")
  end

  def groups(conn, %{"username" => username}) do
    user = Haj.Accounts.get_user_by_username!(username)
    groups = Haj.Spex.get_show_groups_for_user(user.id)

    groups_by_year = Enum.group_by(groups, fn %{show: show} -> show.year end)

    conn
    |> assign(:user, user)
    |> assign(:groups, groups_by_year)
    |> assign(:title, "#{user.first_name} #{user.last_name}: grupper")
    |> render("groups.html")
  end
end
