defmodule HajWeb.ApplicationController do
  use HajWeb, :controller

  alias Haj.Spex
  alias Haj.Applications

  def index(conn, _params) do
    current_spex = Spex.current_spex()
    applications = Applications.list_applications_for_show(current_spex.id)

    conn
    |> assign(:title, "Ansökningar #{current_spex.year.year}")
    |> assign(:show, current_spex)
    |> assign(:applications, applications)
    |> render("index.html")
  end

  def export(conn, _params) do
    current_spex = Spex.current_spex()
    applications = Applications.list_applications_for_show(current_spex.id)
    csv_data = to_csv(applications)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"applications.csv\"")
    |> put_root_layout(false)
    |> send_resp(200, csv_data)
  end

  defp to_csv(applications) do
    titles = ["Namn", "Email", "Telefonnr", "Klass", "Tid", "Grupper", "Övrigt", "Rangordning", "Speciell info"]

    applications =
      Enum.map(applications, fn app ->
        [
          "#{app.user.first_name} #{app.user.last_name}",
          app.user.email,
          app.user.phone,
          app.user.class,
          app.inserted_at,
          all_groups(app),
          app.other,
          app.ranking,
          special_text(app)
        ]
      end)

    CSV.encode([titles | applications]) |> Enum.to_list()
  end

  defp all_groups(application) do
    Enum.map(application.application_show_groups, fn %{show_group: %{group: group}} ->
      group.name
    end)
    |> Enum.join(", ")
  end

  defp special_text(appliaction) do
    Enum.map(appliaction.application_show_groups, fn %{special_text: text} ->
      text
    end) |> Enum.join(";")
  end
end
