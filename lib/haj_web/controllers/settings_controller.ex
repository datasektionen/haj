defmodule HajWeb.SettingsController do
  use HajWeb, :controller

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
