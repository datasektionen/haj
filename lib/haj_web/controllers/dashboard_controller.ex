defmodule HajWeb.DashboardController do
  use HajWeb, :controller

  alias Haj.Merch
  alias Haj.Spex

  def index(conn, _params) do
    current_show = Spex.current_spex()

    user_groups =
      Spex.get_show_groups_for_user(conn.assigns.current_user.id)
      |> Enum.filter(fn %{show: show} -> show.id == current_show.id end)

    conn
    |> assign(:title, "Min Sida")
    |> assign(:user_groups, user_groups)
    |> assign(:current_show, current_show)
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

  def order_merch(conn, _params) do
    user = conn.assigns[:current_user]

    {:ok, order} = Merch.create_or_get_previous_order(user.id)
    options = Merch.list_merch_items()

    conn
    |> assign(:title, "Dina merchbeställningar")
    |> assign(:order, order)
    |> assign(:options, options)
    |> render("merch.html")
  end

  def new_order_item(conn, %{"item_id" => item_id}) do
    user = conn.assigns[:current_user]
    changeset = Merch.change_merch_order_item(%Merch.MerchOrderItem{})

    item = Merch.get_merch_item!(item_id)
    {:ok, order} = Merch.create_or_get_previous_order(user.id)

    if past_deadline?(item) do
      conn
      |> put_flash(:error, "Denna merch går inte att beställa längre")
      |> redirect(to: Routes.dashboard_path(conn, :order_merch))
    else
      render(conn, "new_order_item.html",
        item: item,
        order: order,
        changeset: changeset,
        title: "Ny beställning: #{item.name}"
      )
    end
  end

  def create_order_item(conn, %{"merch_order_item" => params}) do
    case Merch.create_merch_order_item(params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Merch lades till.")
        |> redirect(to: Routes.dashboard_path(conn, :order_merch))

      {:error, %Ecto.Changeset{} = changeset} ->
        %{"merch_item_id" => item_id} = params
        item = Merch.get_merch_item!(item_id)
        {:ok, order} = Merch.create_or_get_previous_order(conn.assigns[:current_user].id)

        render(conn, "new_order_item.html",
          changeset: changeset,
          item: item,
          order: order,
          title: "Ny beställning: #{item.name}"
        )
    end
  end

  def edit_order_item(conn, %{"id" => id}) do
    order_item = Merch.get_merch_order_item!(id) |> Haj.Repo.preload([:merch_order, :merch_item])

    if past_deadline?(order_item.merch_item) do
      conn
      |> put_flash(:error, "Det går inte längre att ändra på denna")
      |> redirect(to: Routes.dashboard_path(conn, :order_merch))
    else
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
    order_item = Merch.get_merch_order_item!(id) |> Haj.Repo.preload(:merch_item)

    if past_deadline?(order_item.merch_item) do
      conn
      |> put_flash(:error, "Det går inte längre att ändra på denna.")
      |> redirect(to: Routes.dashboard_path(conn, :order_merch))
    else
      {:ok, _order} = Merch.delete_merch_order_item(order_item)

      conn
      |> put_flash(:info, "Merch togs bort.")
      |> redirect(to: Routes.dashboard_path(conn, :order_merch))
    end
  end

  defp past_deadline?(item) do
    case item.purchase_deadline && DateTime.compare(item.purchase_deadline, DateTime.utc_now()) do
      :lt -> true
      _ -> false
    end
  end
end
