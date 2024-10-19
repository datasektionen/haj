defmodule Haj.Applications do
  @moduledoc """
  The Applications context.
  """

  import Ecto.Query, warn: false
  alias Haj.Spex.ShowGroup
  alias Haj.Spex
  alias Haj.Repo

  alias Haj.Applications.Application, as: App
  alias Haj.Applications.ApplicationShowGroup

  @doc """
  Returns the list of applications.

  ## Examples

      iex> list_applications()
      [%Application{}, ...]

  """
  def list_applications do
    Repo.all(App)
  end

  @doc """
  Gets a single application.

  Raises `Ecto.NoResultsError` if the Application does not exist.

  ## Examples

      iex> get_application!(123)
      %Application{}

      iex> get_application!(456)
      ** (Ecto.NoResultsError)

  """
  def get_application!(id), do: Repo.get!(App, id)

  @doc """
  Creates an application. Takes a list of show, groups, user id and a show id.
  If there is already a pending application for that show for that user, it updates that application instead.
  """
  def create_application(user_id, show_id, show_groups) do
    Repo.transaction(fn ->
      previous =
        Repo.one(
          from a in App,
            where: a.show_id == ^show_id and a.user_id == ^user_id and a.status == ^:pending,
            preload: :application_show_groups
        )

      if previous != nil do
        prev_sgs = Enum.map(previous.application_show_groups, fn asg -> asg.show_group_id end)
        to_delete = prev_sgs -- show_groups
        to_add = show_groups -- prev_sgs

        Repo.delete_all(
          from a in ApplicationShowGroup,
            where: a.application_id == ^previous.id and a.show_group_id in ^to_delete
        )

        Enum.each(to_add, fn id ->
          Repo.insert(%ApplicationShowGroup{
            application_id: previous.id,
            show_group_id: id
          })
        end)
      else
        {:ok, application} =
          %App{user_id: user_id, show_id: show_id}
          |> Repo.insert()

        Enum.each(show_groups, fn id ->
          Repo.insert(%ApplicationShowGroup{
            application_id: application.id,
            show_group_id: id
          })
        end)
      end
    end)
  end

  @doc """
  Completes a pending application. Deletes all other applications for the user for the same show.
  """
  def complete_application(%App{} = application, attrs) do
    Repo.transaction(fn ->
      app = application |> App.changeset_with_show_groups(attrs) |> Repo.update!()

      Repo.delete_all(
        from a in App,
          where: a.id != ^app.id and a.show_id == ^app.show_id and a.user_id == ^app.user_id
      )

      app
    end)
  end

  @doc """
  Deletes a application.

  ## Examples

      iex> delete_application(application)
      {:ok, %Application{}}

      iex> delete_application(application)
      {:error, %Ecto.Changeset{}}

  """
  def delete_application(%App{} = application) do
    Repo.delete(application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking application changes.

  ## Examples

      iex> change_application(application)
      %Ecto.Changeset{data: %Application{}}

  """
  def change_application(%App{} = application, attrs \\ %{}) do
    App.changeset(application, attrs)
  end

  @doc """
  Returns a list of applications for a show group.
  """
  def get_applications_for_show_group(show_group_id) do
    query =
      from a in App,
        join: asg in assoc(a, :application_show_groups),
        where: asg.application_id == a.id,
        where: asg.show_group_id == ^show_group_id and a.status == ^:submitted,
        preload: [user: [], application_show_groups: [show_group: [group: []]]],
        order_by: [asc: a.updated_at]

    Repo.all(query)
  end

  @doc """
  Returns a list of applicaitons for a user.
  """
  def get_applications_for_user(user_id) do
    query =
      from a in App,
        where: a.user_id == ^user_id,
        preload: [application_show_groups: []]

    Repo.all(query)
  end

  @doc """
  Returns an application for a user for the current show.
  """
  def get_current_application_for_user(user_id) do
    query =
      from a in App,
        where:
          a.user_id == ^user_id and a.show_id == ^Spex.current_spex().id and
            a.status == ^:submitted,
        preload: [application_show_groups: []]

    Repo.one(query)
  end

  @doc """
  Returns an application for a user for the current show.
  """
  def get_pending_application_for_user(user_id) do
    query =
      from a in App,
        where:
          a.user_id == ^user_id and a.show_id == ^Spex.current_spex().id and a.status == ^:pending,
        preload: [application_show_groups: []]

    Repo.one(query)
  end

  @doc """
  Returns a list of show groups for an application.
  """
  def get_show_groups_for_application(application_id) do
    query =
      from sg in ShowGroup,
        join: asg in assoc(sg, :application_show_groups),
        where: asg.application_id == ^application_id,
        preload: :group

    Repo.all(query)
  end

  @doc """
  Returns all application for a show.
  """
  def list_applications_for_show(show_id) do
    query =
      from a in App,
        where: a.show_id == ^show_id and a.status == ^:submitted,
        preload: [application_show_groups: [show_group: [group: []]], user: []],
        order_by: [asc: a.updated_at]

    Repo.all(query)
  end

  @doc """
  Returns true if it is possible to apply for the current show.
  """
  def open?() do
    show = Spex.current_spex()
    current_date = DateTime.now!("Etc/UTC")

    case show.application_opens && DateTime.compare(show.application_opens, current_date) do
      :lt ->
        case DateTime.compare(show.application_closes, current_date) do
          :gt -> true
          _ -> false
        end

      _ ->
        false
    end
  end

  def application_email(user, application, show_groups) do
    spex = Spex.current_spex()

    show_group_names =
      Enum.map_join(
        application.application_show_groups,
        fn sg ->
          show_groups[sg.show_group_id].group.name
        end,
        ", "
      )

    """
    <h2>Tack för din ansökan!</h2>
    <p>Din ansökan till METAspexet #{spex.year.year} har tagits emot. Nedan kommer en sammanfattning av din ansökan:</p>
    <ul>
      <li><b>Namn</b>: #{user.first_name} #{user.last_name}</li>
      <li><b>Mail</b>: #{user.email}</li>
      <li><b>Telefonnummer</b>: #{user.phone}</li>
      <li><b>Sökta grupper</b>: #{show_group_names}</li>
    </ul>
    Du kommer inom kort kontaktas av chefer för de grupper du sökt. Om du har några frågor eller funderingar
    är du välkommen att kontakta Direqtionen på <a href="mailto:direqtionen@metaspexet.se">direqtionen@metaspexet.se</a>.
    <br/><br/>
    Hälsningar,<br/><br/>
    Chefsgruppen för METAspexet #{spex.year.year}
    """
  end

  @spam_url "https://spam.datasektionen.se/api/sendmail"

  def send_email(to, message) do
    spex = Spex.current_spex()
    api_key = Application.get_env(:haj, :spam_api_key)

    HTTPoison.post(
      @spam_url,
      {:form,
       [
         {"from", "metaspexet@datasektionen.se"},
         {"to", to},
         {"subject", "Din ansökan till METAspexet #{spex.year.year}"},
         {"content", message},
         {"template", "metaspexet"},
         {"key", api_key}
       ]}
    )
  end
end
