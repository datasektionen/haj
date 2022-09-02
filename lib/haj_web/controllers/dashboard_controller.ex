defmodule HajWeb.DashboardController do
  use HajWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:title, "Min Sida")
    |> render("index.html")
  end

  def edit_user(conn, _params) do
    user = conn.assigns[:current_user]

    changeset = Haj.Accounts.change_user(user)

    conn
    |> assign(:title, "Dina uppgifter: #{user.first_name} #{user.last_name}")
    |> assign(:changeset, changeset)
    |> render("edit.html")
  end

  def update_user(conn, %{"user" => user_params}) do
    user = conn.assigns[:current_user]

    case Haj.Accounts.update_user(user, user_params) do
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
end
