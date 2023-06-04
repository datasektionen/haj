defmodule HajWeb.MerchAdminController do
  use HajWeb, :controller

  alias Haj.Policy
  alias Haj.Merch

  # Make sure to run authorize plug for all requests
  plug :authorize

  def csv(conn, %{"show_id" => show_id}) do
    orders =
      Merch.list_merch_orders_for_show(show_id)
      |> Haj.Repo.preload([:user, merch_order_items: [:merch_item]])

    csv_data = to_csv(orders)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"merch_orders_spex_#{show_id}.csv\""
    )
    |> put_root_layout(false)
    |> send_resp(200, csv_data)
  end

  defp to_csv(orders) do
    titles = [
      "Namn",
      "Email",
      "KTH-id",
      "Beställnings-id",
      "Merch",
      "Storlek",
      "Antal",
      "Skapad",
      "Ändrad"
    ]

    orders =
      Enum.flat_map(orders, fn order ->
        user = order.user

        Enum.map(order.merch_order_items, fn item ->
          [
            "#{user.first_name} #{user.last_name}",
            user.email,
            user.username,
            order.id,
            item.merch_item.name,
            item.size,
            item.count,
            order.inserted_at,
            order.updated_at
          ]
        end)
      end)

    CSV.encode([titles | orders]) |> Enum.to_list()
  end

  # Makes the comma seperated string sizes in merch params to array
  defp split_merch_comma_separated(merch_params) do
    Map.update(merch_params, "sizes", [], fn str -> String.split(str, ",", trim: true) end)
  end

  # Only "chefer" and admins can interact here
  defp authorize(conn, _) do
    case Policy.authorize(:merch_admin, conn.assigns.current_user) do
      :ok ->
        conn

      _ ->
        conn
        |> put_flash(:error, "Du har inte tillgång till denna sida.")
        |> redirect(to: ~p"/dashboard")
        |> halt()
    end
  end
end
