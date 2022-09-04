defmodule Haj.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Accounts.User
  alias Haj.Accounts.UserToken

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_username!(username) do
    Repo.get_by!(User, username: username)
  end

  @doc """
  Returns a user fetched from `login`,
  if it does't exist in the database, it adds it.
  """
  def upsert_user(%{"user" => name, "emails" => email} = attrs) do
    case Repo.get_by(User, username: name) do
      nil ->
        data = attrs |> Map.put("username", name) |> Map.put("email", email)

        %User{}
        |> User.changeset(data)
        |> Repo.insert!()

      user ->
        user
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  def search_users(search_phrase) do
    start_char = String.slice(search_phrase, 0..1)

    query =
      from u in User,
        where: ilike(u.first_name, ^"#{start_char}%") or ilike(u.last_name, ^"#{start_char}%"),
        where: fragment("SIMILARITY(? || ?,?) > 0", u.first_name, u.last_name, ^search_phrase),
        order_by: fragment("LEVENSHTEIN(? || ?,?) > 0", u.first_name, u.last_name, ^search_phrase)

    Repo.all(query)
  end
end
