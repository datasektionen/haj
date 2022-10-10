defmodule HajWeb.MerchAdminController do
  use HajWeb, :controller

  alias Haj.Merch
  alias Haj.Merch.MerchItem

  def index(conn, %{"show_id" => show_id}) do
    merch = Merch.list_merch_items()
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
        |> redirect(to: Routes.settings_path(conn, :index, show_id))

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
        |> redirect(to: Routes.settings_path(conn, :edit, id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          merch: merch,
          changeset: changeset,
          title: "Redigera merch"
        )
    end
  end

  def delete(conn, %{"id" => id, "show_id" => show_id}) do
    merch = Merch.get_merch_item!(id)
    {:ok, _merch} = Merch.delete_merch_item(merch)

    conn
    |> put_flash(:info, "Merch togs bort.")
    |> redirect(to: Routes.settings_path(conn, :index, show_id))
  end

  # Makes the comma seperated string sizes in merch params to array
  defp split_merch_comma_separated(merch_params) do
    Map.update(merch_params, "sizes", [], fn str -> String.split(str, ",", trim: true) end)
  end
end
