defmodule HajWeb.SettingsController do
  use HajWeb, :controller

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

  def edit_show_groups(conn, %{"show_id" => show_id, "id" => show_group}) do
    show_groups = Haj.Spex.get_current_show_groups()

    conn
    |> assign(:show_groups, show_groups)
    |> assign(:title, "Nuvarande grupper")
    |> render("show_groups/index.html")
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
