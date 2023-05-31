defmodule HajWeb.GroupController do
  use HajWeb, :controller

  def csv(conn, %{"show_group_id" => show_group_id}) do
    show_group = Haj.Spex.get_show_group!(show_group_id)
    users = Enum.map(show_group.group_memberships, fn %{user: user} -> user end)

    if is_admin?(conn, show_group) do
      csv_data = to_csv(users)

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"medlemmar.csv\"")
      |> put_root_layout(false)
      |> send_resp(200, csv_data)
    else
      conn
      |> put_flash(:error, "Du har inte behörighet")
      |> redirect(to: ~p"/dashboard")
    end
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

  defp is_admin?(conn, show_group) do
    conn.assigns.current_user.role == :admin ||
      show_group.group_memberships
      |> Enum.any?(fn %{user_id: id, role: role} ->
        role == :chef && id == conn.assigns.current_user.id
      end)
  end
end
