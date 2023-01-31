defmodule Haj.Responsibilities do
  @moduledoc """
  The Responsibilities context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Responsibilities.Responsibility

  @doc """
  Returns the list of responsibilities.

  ## Examples

      iex> list_responsibilities()
      [%Responsibility{}, ...]

  """
  def list_responsibilities do
    Repo.all(Responsibility)
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

  alias Haj.Responsibilities.Comment

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
end
