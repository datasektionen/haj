defmodule Haj.Applications do
  @moduledoc """
  The Applications context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Applications.Application
  alias Haj.Applications.ApplicationShowGroup

  @doc """
  Returns the list of applications.

  ## Examples

      iex> list_applications()
      [%Application{}, ...]

  """
  def list_applications do
    Repo.all(Application)
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
  def get_application!(id), do: Repo.get!(Application, id)

  @doc """
  Creates an application. Takes a list of show, groups, user id and a show id.
  If there is already an application for that show for that user, replaces and creates a new applicaiton.
  """
  def create_application(
        %{"show_groups" => show_groups, "user_id" => user_id, "show_id" => show_id} = attrs \\ %{}
      ) do
    Repo.transaction(fn ->
      previous =
        Repo.one(from a in Application, where: a.show_id == ^show_id and a.user_id == ^user_id)

      if previous != nil do
        {:ok, _} = Repo.delete(previous)
      end

      {:ok, application} =
        %Application{}
        |> Application.changeset(attrs)
        |> Repo.insert()

      Enum.each(show_groups, fn %{id: id, special_text: text} ->
        Repo.insert(%ApplicationShowGroup{
          application_id: application.id,
          show_group_id: id,
          special_text: text
        })
      end)
    end)
  end

  @doc """
  Updates a application.

  ## Examples

      iex> update_application(application, %{field: new_value})
      {:ok, %Application{}}

      iex> update_application(application, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_application(%Application{} = application, attrs) do
    application
    |> Application.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a application.

  ## Examples

      iex> delete_application(application)
      {:ok, %Application{}}

      iex> delete_application(application)
      {:error, %Ecto.Changeset{}}

  """
  def delete_application(%Application{} = application) do
    Repo.delete(application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking application changes.

  ## Examples

      iex> change_application(application)
      %Ecto.Changeset{data: %Application{}}

  """
  def change_application(%Application{} = application, attrs \\ %{}) do
    Application.changeset(application, attrs)
  end

  @doc """
  Returns a list of applications for a show group.
  """
  def get_applications_for_show_group(show_group_id) do
    query =
      from a in Application,
        join: asg in assoc(a, :application_show_groups),
        where: asg.application_id == a.id,
        where: asg.show_group_id == ^show_group_id,
        preload: [user: [], application_show_groups: [show_group: [group: []]]]

    Repo.all(query)
  end

  @doc """
  Returns a list of applicaitons for a user.
  """
  def get_applications_for_user(user_id) do
    query =
      from a in Application,
        where: a.user_id == ^user_id,
        preload: [application_show_groups: []]

    Repo.all(query)
  end

  @doc """
  Returns all application for a show.
  """
  def list_applications_for_show(show_id) do
    query =
      from a in Application,
        where: a.show_id == ^show_id,
        preload: [application_show_groups: [show_group: [group: []]], user: []]

    Repo.all(query)
  end
end
