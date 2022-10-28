defmodule HajWeb.DashboardController do
  use HajWeb, :controller

  def index(conn, _params) do
    current_show = Haj.Spex.current_spex()

    user_groups =
      Haj.Spex.get_show_groups_for_user(conn.assigns.current_user.id)
      |> Enum.filter(fn %{show: show} -> show.id == current_show.id end)

    conn
    |> assign(:title, "Min Sida")
    |> assign(:user_groups, user_groups)
    |> render("index.html")
  end

  def edit_user(conn, _params) do
    user = conn.assigns[:current_user] |> Haj.Repo.preload(:foods)
    food_options = Haj.Foods.list_foods()

    changeset = Haj.Accounts.change_user(user)

    conn
    |> assign(:title, "Dina uppgifter: #{user.first_name} #{user.last_name}")
    |> assign(:food_options, food_options)
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update_user(conn, %{"user" => user_params}) do
    user = conn.assigns[:current_user] |> Haj.Repo.preload(:foods)
    foods = Haj.Foods.list_foods_with_ids(user_params["foods_ids"] || [])
    food_options = Haj.Foods.list_foods()

    changeset =
      Haj.Accounts.change_user(user, user_params)
      |> Ecto.Changeset.put_assoc(:foods, foods)

    case Haj.Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Ändringen sparades.")
        |> redirect(to: Routes.dashboard_path(conn, :edit_user))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Något fylldes i fel, kolla fel nedan.")
        |> assign(:title, "Dina uppgifter: #{user.first_name} #{user.last_name}")
        |> assign(:food_options, food_options)
        |> assign(:changeset, changeset)
        |> render("edit.html")
    end
  end
end
