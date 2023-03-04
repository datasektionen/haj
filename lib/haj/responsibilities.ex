defmodule Haj.Responsibilities do
  @moduledoc """
  The Responsibilities context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Spex.Show
  alias Haj.Accounts.User
  alias Haj.Responsibilities.Responsibility
  alias Haj.Responsibilities.ResponsibleUser
  alias Haj.Responsibilities.Comment

  @doc """
  Returns the list of responsibilities.

  ## Examples

      iex> list_responsibilities()
      [%Responsibility{responsible_users: [%User{}, ...]}, ...]

  """
  def list_responsibilities do
    current_spex = Haj.Spex.current_spex()

    query =
      from r in Responsibility,
        left_join: ru in ResponsibleUser,
        on: r.id == ru.responsibility_id and ru.show_id == ^current_spex.id,
        left_join: u in assoc(ru, :user),
        preload: [responsible_users: u]

    # select: %{responsibility: r, user: u}

    Repo.all(query)
  end

  @doc """
  Gets a single responsibility.

  Raises `Ecto.NoResultsError` if the Responsibility does not exist.

  ## Examples

      iex> get_responsibility!(123)
      %Responsibility{}

      iex> get_responsibility!(456)
      ** (Ecto.NoResultsError)

  """
  def get_responsibility!(id), do: Repo.get!(Responsibility, id)

  @doc """
  Creates a responsibility.

  ## Examples

      iex> create_responsibility(%{field: value})
      {:ok, %Responsibility{}}

      iex> create_responsibility(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_responsibility(attrs \\ %{}) do
    %Responsibility{}
    |> Responsibility.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a responsibility.

  ## Examples

      iex> update_responsibility(responsibility, %{field: new_value})
      {:ok, %Responsibility{}}

      iex> update_responsibility(responsibility, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_responsibility(%Responsibility{} = responsibility, attrs) do
    responsibility
    |> Responsibility.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a responsibility.

  ## Examples

      iex> delete_responsibility(responsibility)
      {:ok, %Responsibility{}}

      iex> delete_responsibility(responsibility)
      {:error, %Ecto.Changeset{}}

  """
  def delete_responsibility(%Responsibility{} = responsibility) do
    Repo.delete(responsibility)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking responsibility changes.

  ## Examples

      iex> change_responsibility(responsibility)
      %Ecto.Changeset{data: %Responsibility{}}

  """
  def change_responsibility(%Responsibility{} = responsibility, attrs \\ %{}) do
    Responsibility.changeset(responsibility, attrs)
  end

  @doc """
  Returns the list of responsibility_comments.

  ## Examples

      iex> list_responsibility_comments()
      [%Comment{}, ...]

  """
  def list_responsibility_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  def get_comments_for_show(responsibility, show_id) do
    query =
      from c in Comment,
        where: c.responsibility_id == ^responsibility.id and c.show_id == ^show_id,
        order_by: [asc: c.inserted_at],
        preload: [:user]

    Repo.all(query)
  end

  @doc """
  Returns the list of responsibility_users.

  ## Examples

      iex> list_responsibility_users()
      [%ResponsibleUser{}, ...]

  """
  def list_responsibility_users do
    Repo.all(ResponsibleUser)
  end

  @doc """
  Gets a single responsible_user.

  Raises `Ecto.NoResultsError` if the Responsible user does not exist.

  ## Examples

      iex> get_responsible_user!(123)
      %ResponsibleUser{}

      iex> get_responsible_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_responsible_user!(id), do: Repo.get!(ResponsibleUser, id)

  @doc """
  Creates a responsible_user.

  ## Examples

      iex> create_responsible_user(%{field: value})
      {:ok, %ResponsibleUser{}}

      iex> create_responsible_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_responsible_user(attrs \\ %{}) do
    %ResponsibleUser{}
    |> ResponsibleUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a responsible_user.

  ## Examples

      iex> update_responsible_user(responsible_user, %{field: new_value})
      {:ok, %ResponsibleUser{}}

      iex> update_responsible_user(responsible_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_responsible_user(%ResponsibleUser{} = responsible_user, attrs) do
    responsible_user
    |> ResponsibleUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a responsible_user.

  ## Examples

      iex> delete_responsible_user(responsible_user)
      {:ok, %ResponsibleUser{}}

      iex> delete_responsible_user(responsible_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_responsible_user(%ResponsibleUser{} = responsible_user) do
    Repo.delete(responsible_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking responsible_user changes.

  ## Examples

      iex> change_responsible_user(responsible_user)
      %Ecto.Changeset{data: %ResponsibleUser{}}

  """
  def change_responsible_user(%ResponsibleUser{} = responsible_user, attrs \\ %{}) do
    ResponsibleUser.changeset(responsible_user, attrs)
  end

  @doc """
  Returns the list of responsible_users for a responsibility, grouped by show.

  ## Examples

      iex> get_all_responsible_users_for_responsibility(1)
      [%{show: %Show{}, users: [%User{}, ...]}, ...]
  """
  def get_all_responsible_users_for_responsibility(responsibility_id) do
    query =
      from show in Show,
        left_join: ru in ResponsibleUser,
        on: ru.show_id == show.id and ru.responsibility_id == ^responsibility_id,
        left_join: u in User,
        on: u.id == ru.user_id,
        group_by: [show.id, u.id],
        select: %{show: show, user: u}

    Repo.all(query)
    |> Enum.group_by(& &1.show)
    |> Enum.map(fn {show, users} ->
      %{show: show, users: Enum.map(users, & &1.user)}
    end)
    |> Enum.map(fn %{users: users} = map ->
      case users do
        [nil] -> %{map | users: []}
        _ -> map
      end
    end)
    |> Enum.sort_by(fn %{show: show} -> show.year end, {:desc, Date})
  end
end
