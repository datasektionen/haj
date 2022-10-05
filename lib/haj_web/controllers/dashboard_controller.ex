defmodule HajWeb.DashboardController do
  use HajWeb, :controller

  alias Haj.Merch
  alias Haj.Spex

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

    changeset =
      Haj.Accounts.change_user(user, user_params)
      |> Ecto.Changeset.put_assoc(:foods, foods)

    case Haj.Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Ändringen sparades.")
        |> redirect(to: Routes.dashboard_path(conn, :edit_user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          changeset: changeset,
          title: "Dina uppgifter: #{user.first_name} #{user.last_name}"
        )
    end
  end

  def order_merch(conn, _params) do
    user = conn.assigns[:current_user]
    current_show = Spex.current_spex()

    orders =
      Merch.get_merch_orders_for_user(user.id)
      |> Enum.filter(fn %{show_id: show_id} -> show_id == current_show.id end)

    prev_order =
      case orders do
        [] -> nil
        [o] -> o
      end

    options = Merch.list_merch_items()

    # options =
    #   case prev_order do
    #     nil ->
    #       options

    #     order ->
    #       options
    #       |> Enum.filter(fn %{id: id} ->
    #         !Enum.any?(order.merch_order_items, fn %{merch_item_id: item_id} -> id == item_id end)
    #       end)
    #   end

    conn
    |> assign(:title, "Dina merchbeställningar")
    |> assign(:order, prev_order)
    |> assign(:options, options)
    |> render("merch.html")
  end

  def new_order_item(conn, %{"item_id" => item_id}) do
    changeset = Merch.change_merch_order_item(%Merch.MerchOrderItem{})
    current_show = Spex.current_spex()
    orders =
      Merch.get_merch_orders_for_user(conn.assigns[:current_user].id)
      |> Enum.filter(fn %{show_id: show_id} -> show_id == current_show.id end)

    item = Merch.get_merch_item!(item_id)

    prev_order =
      case orders do
        [] -> nil
        [o] -> o
      end

    render(conn, "new_order_item.html",
      item: item,
      order: prev_order,
      changeset: changeset,
      title: "Ny beställning: #{item.name}"
    )
  end

  def create_order_item(conn, %{"merch_order_item" => params}) do
    case Merch.create_merch_order_item(params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Merch lades till.")
        |> redirect(to: Routes.dashboard_path(conn, :order_merch))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_order_item.html",
          changeset: changeset,
          title: "Redigera rad"
        )
    end
  end

  def edit_order_item(conn, %{"id" => id}) do
    order_item = Merch.get_merch_order_item!(id) |> Haj.Repo.preload(:merch_order)

    if order_item.merch_order.user_id == conn.assigns[:current_user].id do
      changeset = Merch.change_merch_order_item(order_item)

      render(conn, "edit_order_item.html",
        order_item: order_item,
        changeset: changeset,
        title: "Redigera rad"
      )
    else
      conn
      |> put_flash(:error, "Du kan inte ändra på andras beställningar.")
      |> redirect(to: Routes.dashboard_path(conn, :order_merch))
    end
  end

  def update_order_item(conn, %{"id" => id, "merch_order_item" => params}) do
    order_item = Merch.get_merch_order_item!(id) |> Haj.Repo.preload(:merch_order)

    if order_item.merch_order.user_id == conn.assigns[:current_user].id do
      case Merch.update_merch_order_item(order_item, params) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Rad uppdaterades.")
          |> redirect(to: Routes.dashboard_path(conn, :order_merch))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit_order_item.html",
            order_item: order_item,
            changeset: changeset,
            title: "Redigera rad"
          )
      end
    else
      conn
      |> put_flash(:error, "Du kan inte ändra på andras beställningar.")
      |> redirect(to: Routes.dashboard_path(conn, :order_merch))
    end
  end

  def delete_order_item(conn, %{"id" => id}) do
    order_item = Merch.get_merch_order_item!(id)
    {:ok, _order} = Merch.delete_merch_order_item(order_item)

    conn
    |> put_flash(:info, "Merch togs bort.")
    |> redirect(to: Routes.dashboard_path(conn, :order_merch))
  end
end
