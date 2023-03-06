defmodule HajWeb.SettingsController do
  use HajWeb, :controller

  alias Haj.Accounts.User
  alias Haj.Foods
  alias Haj.Foods.Food

  plug :authorize

  def index(conn, _params) do
    conn |> assign(:title, "Administrera") |> render("index.html")
  end

  def groups(conn, _params) do
    groups = Haj.Spex.list_groups()

    conn
    |> assign(:title, "Administrera grupper")
    |> assign(:groups, groups)
    |> render("groups/index.html")
  end

  def new_group(conn, _params) do
    changeset = Haj.Spex.change_group(%Haj.Spex.Group{})

    conn
    |> assign(:changeset, changeset)
    |> assign(:title, "Ny grupp")
    |> render("groups/new.html")
  end

  def edit_group(conn, %{"id" => id}) do
    group = Haj.Spex.get_group!(id)
    changeset = Haj.Spex.change_group(group)

    conn
    |> assign(:changeset, changeset)
    |> assign(:group, group)
    |> assign(:title, "Redigera: #{group.name}")
    |> render("groups/edit.html")
  end

  def update_group(conn, %{"id" => id, "group" => group_params}) do
    group = Haj.Spex.get_group!(id)

    case Haj.Spex.update_group(group, group_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Grupp uppdaterades.")
        |> redirect(to: Routes.settings_path(conn, :groups))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "groups/edit.html", group: group, changeset: changeset)
    end
  end

  def create_group(conn, %{"group" => group_paramss}) do
    case Haj.Spex.create_group(group_paramss) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Grupp skapades.")
        |> redirect(to: Routes.settings_path(conn, :groups))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "groups/new.html", changeset: changeset)
    end
  end

  def delete_group(conn, %{"id" => id}) do
    group = Haj.Spex.get_group!(id)
    {:ok, _} = Haj.Spex.delete_group(group)

    conn
    |> put_flash(:info, "Grupp raderades.")
    |> redirect(to: Routes.settings_path(conn, :groups))
  end

  def show_groups(conn, %{"show_id" => show_id}) do
    show_groups = Haj.Spex.get_show_groups_for_show(show_id)
    show = Haj.Spex.get_show!(show_id)

    groups =
      Haj.Spex.list_groups()
      |> Enum.filter(fn %{id: id} ->
        !Enum.any?(show_groups, fn %{group: %{id: g_id}} -> g_id == id end)
      end)

    conn
    |> assign(:show_groups, show_groups)
    |> assign(:show, show)
    |> assign(:groups, groups)
    |> assign(:title, "Nuvarande grupper")
    |> render("show_groups/index.html")
  end

  def add_show_group(conn, %{"show_id" => show_id, "group" => group_id}) do
    case Haj.Spex.create_show_group(%{group_id: group_id, show_id: show_id}) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Grupp lades till.")
        |> redirect(to: Routes.settings_path(conn, :show_groups, show_id))

      {:error, _} ->
        conn
        |> put_flash(:error, "Misslyckades lägga till grupp.")
        |> redirect(to: Routes.settings_path(conn, :show_groups, show_id))
    end
  end

  def delete_show_group(conn, %{"id" => id}) do
    show_group = Haj.Spex.get_show_group!(id)
    {:ok, _} = Haj.Spex.delete_show_group(show_group)

    conn
    |> put_flash(:info, "Grupp togs bort.")
    |> redirect(to: Routes.settings_path(conn, :show_groups, show_group.show_id))
  end

  def edit_show_group(conn, %{"id" => id}) do
    show_group = Haj.Spex.get_show_group!(id)

    conn
    |> assign(:show_group, show_group)
    |> assign(:title, "#{show_group.group.name} #{show_group.show.year.year}")
    |> render("show_groups/edit.html")
  end

  def shows(conn, _oarams) do
    shows = Haj.Spex.list_shows()

    conn
    |> assign(:shows, shows)
    |> assign(:title, "Alla spex")
    |> render("shows/index.html")
  end

  def new_show(conn, _params) do
    changeset = Haj.Spex.change_show(%Haj.Spex.Show{})

    conn
    |> assign(:title, "Nytt spex")
    |> assign(:changeset, changeset)
    |> render("shows/new.html")
  end

  def create_show(conn, %{"show" => show_params}) do
    case Haj.Spex.create_show(show_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Spex skapades.")
        |> redirect(to: Routes.settings_path(conn, :shows))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "shows/new.html", changeset: changeset)
    end
  end

  def edit_show(conn, %{"id" => id}) do
    show = Haj.Spex.get_show!(id)
    changeset = Haj.Spex.change_show(show)

    conn
    |> assign(:show, show)
    |> assign(:title, "Redigera spex")
    |> assign(:changeset, changeset)
    |> render("shows/edit.html")
  end

  def update_show(conn, %{"id" => id, "show" => show_params}) do
    show = Haj.Spex.get_show!(id)

    case Haj.Spex.update_show(show, show_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Spex uppdaterades.")
        |> redirect(to: Routes.settings_path(conn, :shows))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "shows/edit.html", show: show, changeset: changeset)
    end
  end

  def users(conn, _params) do
    users =
      Haj.Accounts.list_users()
      |> Enum.sort_by(fn %User{first_name: name} -> name end)
      |> Enum.group_by(fn %User{role: role} -> role end)
      |> Map.put_new(:admin, [])
      |> Map.put_new(:chef, [])
      |> Map.put_new(:spexare, [])
      |> Map.put_new(:none, [])

    conn
    |> assign(:users, users)
    |> assign(:title, "Användare")
    |> render("users/index.html")
  end

  def edit_user(conn, %{"id" => id}) do
    user = Haj.Accounts.get_user!(id)
    changeset = Haj.Accounts.change_user(user)

    conn
    |> assign(:user, user)
    |> assign(:title, "Redigera #{user.first_name} #{user.last_name}")
    |> assign(:changeset, changeset)
    |> render("users/edit.html")
  end

  def update_user(conn, %{"id" => id, "user" => user_params}) do
    user = Haj.Accounts.get_user!(id)

    case Haj.Accounts.update_user(user, user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Användare uppdaterades.")
        |> redirect(to: Routes.settings_path(conn, :users))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "users/edit.html", user: user, changeset: changeset)
    end
  end

  def foods(conn, _params) do
    foods = Foods.list_foods()
    render(conn, "foods/index.html", foods: foods, title: "Matpreferenser")
  end

  def new_food(conn, _params) do
    changeset = Foods.change_food(%Food{})
    render(conn, "foods/new.html", changeset: changeset, title: "Ny matpreferens")
  end

  def create_food(conn, %{"food" => food_params}) do
    case Foods.create_food(food_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Mat skapades.")
        |> redirect(to: Routes.settings_path(conn, :foods))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "foods/new.html", changeset: changeset)
    end
  end

  def edit_food(conn, %{"id" => id}) do
    food = Foods.get_food!(id)
    changeset = Foods.change_food(food)

    render(conn, "foods/edit.html",
      food: food,
      changeset: changeset,
      title: "Redigera matpreferens"
    )
  end

  def update_food(conn, %{"id" => id, "food" => food_params}) do
    food = Foods.get_food!(id)

    case Foods.update_food(food, food_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Mat uppdaterades.")
        |> redirect(to: Routes.settings_path(conn, :foods))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "foods/edit.html", food: food, changeset: changeset)
    end
  end

  def delete_food(conn, %{"id" => id}) do
    food = Foods.get_food!(id)
    {:ok, _food} = Foods.delete_food(food)

    conn
    |> put_flash(:info, "Mat togs bort.")
    |> redirect(to: Routes.settings_path(conn, :foods))
  end

  def csv(conn, %{"id" => show_id}) do
    users = Haj.Spex.list_members_for_show(show_id)

    csv_data = to_csv(users)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"medlemmar.csv\"")
    |> put_root_layout(false)
    |> send_resp(200, csv_data)
  end

  defp to_csv(users) do
    titles = [
      "Namn",
      "Email",
      "KTH-id",
      "Telefonnr",
      "Klass",
      "Google-konto",
      "Personnr",
      "Adress",
      "Postkod",
      "Postort"
    ]

    users =
      Enum.map(users, fn u ->
        [
          "#{u.first_name} #{u.last_name}",
          u.email,
          u.username,
          u.phone,
          u.class,
          u.google_account,
          u.personal_number,
          u.street,
          u.zip,
          u.city
        ]
      end)

    CSV.encode([titles | users]) |> Enum.to_list()
  end

  defp authorize(conn, _) do
    if conn.assigns.current_user.role == :admin do
      current_spex = Haj.Spex.current_spex()
      conn |> assign(:current_spex, current_spex)
    else
      conn
      |> put_flash(:error, "Du har inte tillgång till denna sida.")
      |> redirect(to: Routes.dashboard_path(conn, :index))
      |> halt()
    end
  end
end
