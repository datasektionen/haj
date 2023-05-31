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

    case is_admin?(conn, show_group) do
      true ->
        conn
        |> assign(:show_group, show_group)
        |> assign(:title, "Redigera: #{show_group.group.name} #{show_group.show.year.year}")
        |> render("edit.html")

      false ->
        conn
        |> put_flash(:error, "Du har inte rättigheter att redigera gruppen.")
        |> redirect(to: Routes.group_index_path(conn, :group, show_group_id))
    end
  end

  def applications(conn, %{"show_group_id" => show_group_id}) do
    show_group = Haj.Spex.get_show_group!(show_group_id)
    applications = Haj.Applications.get_applications_for_show_group(show_group_id)

    case is_admin?(conn, show_group) do
      true ->
        conn
        |> assign(:show_group, show_group)
        |> assign(:applications, applications)
        |> assign(:title, "Ansökningar: #{show_group.group.name} #{show_group.show.year.year}")
        |> render("applications.html")

      false ->
        conn
        |> put_flash(:error, "Du har inte rättigheter att se ansökningar.")
        |> redirect(to: Routes.group_index_path(conn, :group, show_group_id))
    end
  end

  def accept_user(conn, %{"show_group_id" => show_group_id, "user_id" => user_id}) do
    show_group = Haj.Spex.get_show_group!(show_group_id)
    user = Haj.Accounts.get_user!(user_id)
    user_groups = Haj.Spex.get_show_groups_for_user(user_id)

    case is_admin?(conn, show_group) do
      true ->
        if user.role == :none do
          {:ok, _} = Haj.Accounts.update_user(user, %{"role" => "spexare"})
        end

        if Enum.any?(user_groups, fn %{id: id} -> id == show_group_id |> String.to_integer() end) do
          conn
          |> put_flash(
            :error,
            "#{user.first_name} #{user.last_name} är redan medlem i #{show_group.group.name}."
          )
          |> redirect(to: Routes.group_index_path(conn, :applications, show_group_id))
        else
          {:ok, _} =
            Haj.Spex.create_group_membership(%{
              user_id: user_id,
              show_group_id: show_group_id,
              role: :gruppis
            })

          conn
          |> put_flash(
            :info,
            "#{user.first_name} #{user.last_name} antogs till #{show_group.group.name}."
          )
          |> redirect(to: Routes.group_index_path(conn, :applications, show_group_id))
        end

      false ->
        conn
        |> put_flash(:error, "Du har inte rättigheter att anta medlemmar.")
        |> redirect(to: Routes.group_index_path(conn, :group, show_group_id))
    end
  end

  def csv(conn, %{"show_group_id" => show_group_id}) do
    show_group = Haj.Spex.get_show_group!(show_group_id)
    users = Enum.map(show_group.group_memberships, fn %{user: user} -> user end)

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

  def vcard(conn, %{"show_group_id" => show_group_id}) do
    show_group = Haj.Spex.get_show_group!(show_group_id)
    users = Enum.map(show_group.group_memberships, fn %{user: user} -> user end)

    vcard = Haj.Accounts.to_vcard(users, show_group.show)

    conn
    |> put_resp_content_type("text/x-vcard")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"#{show_group.group.name}-#{show_group.show.year.year}.vcf\""
    )
    |> put_root_layout(false)
    |> send_resp(200, vcard)
  end

  defp is_admin?(conn, show_group) do
    conn.assigns.current_user.role == :admin ||
      show_group.group_memberships
      |> Enum.any?(fn %{user_id: id, role: role} ->
        role == :chef && id == conn.assigns.current_user.id
      end)
  end
end
