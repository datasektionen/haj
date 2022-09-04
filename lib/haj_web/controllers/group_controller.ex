defmodule HajWeb.GroupController do
  use HajWeb, :controller

  alias Haj.Spex

  def index(conn, _params) do
    current_show = Spex.current_spex()

    groups = Spex.get_show_groups_for_show(current_show.id)

    conn
    |> assign(:groups, groups)
    |> assign(:title, "Grupper")
    |> render("index.html")
  end

  def group(conn, %{"show_group_id" => id}) do
    show_group = Spex.get_show_group!(id)

    conn
    |> assign(:show_group, show_group)
    |> assign(:title, "#{show_group.group.name} #{show_group.show.year.year}")
    |> render("group.html")
  end

  def edit(conn, %{"show_group_id" => show_group_id}) do
    show_group = Haj.Spex.get_show_group!(show_group_id)

    is_admin =
      show_group.group_memberships
      |> Enum.any?(fn %{user_id: id, role: role} ->
        role == :chef && id == conn.assigns.current_user.id
      end)

    case is_admin do
      true ->
        conn
        |> assign(:show_group, show_group)
        |> assign(:title, "Redigera: #{show_group.group.name} #{show_group.show.year.year}")
        |> render("edit.html")

      false ->
        conn
        |> put_flash(:error, "Du har inte rättigheter att redigera gruppen.")
        |> redirect(to: Routes.group_path(conn, :group, show_group_id))
    end
  end
end
