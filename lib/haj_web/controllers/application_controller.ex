defmodule HajWeb.ApplicationController do
  use HajWeb, :controller

  alias Haj.Spex
  alias Haj.Applications
  alias Haj.Repo

  # List all applications for the current show
  def index(conn, _params) do
    current_spex = Spex.current_spex()
    applications = Applications.list_applications_for_show(current_spex.id)

    conn
    |> assign(:title, "Ansökningar #{current_spex.year.year}")
    |> assign(:show, current_spex)
    |> assign(:applications, applications)
    |> render("index.html")
  end

  def edit(conn, %{"id" => id}) do
    case Applications.get_application(id) do
      nil ->
        conn
        |> put_flash(:error, "Application not found")
        |> redirect(to: ~p"/dashboard")

      application ->
        if application.user_id == conn.assigns.current_user.id do
          # Preload the application with user and show groups (including the group association)
          application =
            Repo.preload(application, [
              :user,
              application_show_groups: [show_group: :group]
            ])

          # Get the current show and preload its groups
          current_spex =
            Spex.current_spex()
            |> Repo.preload(show_groups: :group)

          # Prepare the groups options for the form
          groups_options =
            Enum.map(current_spex.show_groups, fn sg ->
              {sg.group.name, sg.group.id}
            end)

          # Get the selected group IDs for the application
          selected_group_ids =
            Enum.map(application.application_show_groups, fn asg ->
              asg.show_group.group.id
            end)

          # Prepare the changeset with the selected group IDs
          changeset =
            Applications.change_application_with_show_groups(application, %{
              group_ids: selected_group_ids
            })

          render(conn, :edit,
            application: application,
            changeset: changeset,
            groups_options: groups_options
          )
        else
          conn
          |> put_flash(:error, "Du kan inte redigera någon annans ansökan.")
          |> redirect(to: ~p"/dashboard")
        end
    end
  end

  def update(conn, %{"id" => id, "application" => application_params}) do
    application = Applications.get_application!(id)

    if application.user_id == conn.assigns.current_user.id do
      case Applications.update_application(application, application_params) do
        {:ok, application} ->
          conn
          |> put_flash(:info, "Ansökan uppdaterades!")
          |> redirect(to: ~p"/applications/#{application}")

        {:error, %Ecto.Changeset{} = changeset} ->
          current_spex = Spex.current_spex() |> Repo.preload(show_groups: :group)
          groups_options = Enum.map(current_spex.show_groups, fn sg -> {sg.group.name, sg.group.id} end)
          render(conn, :edit, application: application, changeset: changeset, groups_options: groups_options)
      end
    else
      conn
      |> put_flash(:error, "Du kan inte redigera någon annans ansökan.")
      |> redirect(to: ~p"/dashboard")
    end
  end

  def delete(conn, %{"id" => id}) do
    application = Applications.get_application!(id)

    if application.user_id == conn.assigns.current_user.id do
      {:ok, _application} = Applications.delete_application(application)

      conn
      |> put_flash(:info, "Ansökan raderades.")
      |> redirect(to: ~p"/dashboard")
    else
      conn
      |> put_flash(:error, "Du kan inte radera någon annans ansökan.")
      |> redirect(to: ~p"/dashboard")
    end
  end

  # Export applications as CSV
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

  # Helper function to convert applications to CSV format
  defp to_csv(applications) do
    titles = [
      "Namn",
      "Email",
      "Telefonnr",
      "Klass",
      "Tid",
      "Grupper",
      "Övrigt",
      "Rangordning",
      "Speciell info"
    ]

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

  # Helper function to list all groups associated with an application
  defp all_groups(application) do
    Enum.map(application.application_show_groups, fn %{show_group: %{group: group}} ->
      group.name
    end)
    |> Enum.join(", ")
  end

  # Helper function to concatenate special texts
  defp special_text(application) do
    Enum.map(application.application_show_groups, fn %{special_text: text} ->
      text
    end)
    |> Enum.join(";")
  end
end
