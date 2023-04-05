defmodule HajWeb.MerchAdminController do
  use HajWeb, :controller

  alias Haj.Policy
  alias Haj.Merch
  alias Haj.Merch.MerchItem

  # Make sure to run authorize plug for all requests
  plug :authorize

  def index(conn, %{"show_id" => show_id}) do
    merch = Merch.list_merch_items_for_show(show_id)
    show = Haj.Spex.get_show!(show_id)
    render(conn, "index.html", merch: merch, title: "Administrera merch", show: show)
  end

  def new(conn, %{"show_id" => show_id}) do
    changeset = Merch.change_merch_item(%MerchItem{})
    show = Haj.Spex.get_show!(show_id)

    render(conn, "new.html", changeset: changeset, show: show, title: "Ny merch")
  end

  def create(conn, %{"merch_item" => merch_params, "show_id" => show_id}) do
    case Merch.create_merch_item(
           merch_params
           |> split_merch_comma_separated()
           |> Map.put("show_id", show_id)
         ) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Merch skapades.")
        |> redirect(to: Routes.merch_admin_path(conn, :index, show_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, title: "Ny merch", show: show_id)
    end
  end

  def edit(conn, %{"id" => id}) do
    show = Haj.Spex.current_spex()
    merch = Merch.get_merch_item!(id)
    changeset = Merch.change_merch_item(merch)

    render(conn, "edit.html",
      merch: merch,
      show: show,
      changeset: changeset,
      title: "Redigera merch"
    )
  end

  def update(conn, %{"id" => id, "merch_item" => merch_params}) do
    merch = Merch.get_merch_item!(id)

    case Merch.update_merch_item(merch, merch_params |> split_merch_comma_separated()) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Merch uppdaterades.")
        |> redirect(to: Routes.merch_admin_path(conn, :edit, id))

      {:error, %Ecto.Changeset{} = changeset} ->
        show = Haj.Spex.current_spex()

        render(conn, "edit.html",
          merch: merch,
          changeset: changeset,
          show: show,
          title: "Redigera merch"
        )
    end
  end

  def delete(conn, %{"id" => id, "show_id" => show_id}) do
    merch = Merch.get_merch_item!(id)
    {:ok, _merch} = Merch.delete_merch_item(merch)

    conn
    |> put_flash(:info, "Merch togs bort.")
    |> redirect(to: Routes.merch_admin_path(conn, :index, show_id))
  end

  def orders(conn, %{"show_id" => show_id}) do
    show = Haj.Spex.get_show!(show_id)

    orders =
      Haj.Merch.list_merch_orders_for_show(show_id)
      |> Haj.Repo.preload([:user, merch_order_items: [:merch_item]])

    order_summary = Haj.Merch.get_merch_order_summary(show_id)

    render(conn, "orders.html",
      orders: orders,
      order_summary: order_summary,
      title: "Beställningar",
      show: show
    )
  end

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
