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
    |> Repo.insert(returning: [:full_name])
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

  @doc """
  Searches for users based on a search phrase.
  """
  def search_users(search_phrase) do
    query =
      from u in User,
        where: fragment("? <% ?", ^search_phrase, u.full_name),
        order_by: {:desc, fragment("? <% ?", ^search_phrase, u.full_name)}

    Repo.all(query)
  end

  @doc """
  Searches for spex users based on a search phrase, only returns users that have been part of a spex.
  """
  def search_spex_users(search_phrase, options \\ []) do
    include_rank = Keyword.get(options, :rank, false)

    base_query =
      from u in User,
        where: fragment("? <% ?", ^search_phrase, u.full_name) and u.role != :none,
        order_by: {:desc, fragment("? <% ?", ^search_phrase, u.full_name)}

    query =
      if include_rank do
        from u in base_query,
          select: {u, fragment("word_similarity(?, ?)", ^search_phrase, u.full_name)}
      else
        base_query
      end

    Repo.all(query)
  end

  @doc """
  Creates a vcard string based on users and show, the show is needed to create organization year
  """
  def to_vcard(users, show) do
    Enum.map(users, &user_vcard(&1, show))
    |> Enum.join("\r\n")
  end

  defp user_vcard(user, show) do
    clrf = "\r\n"

    "BEGIN:VCARD" <>
      clrf <>
      "VERSION:3.0" <>
      clrf <>
      "N:#{user.last_name};#{user.first_name};;;" <>
      clrf <>
      "FN:#{user.first_name} #{user.last_name}" <>
      clrf <>
      "ORG:Metaspexet #{show.year.year}" <>
      clrf <>
      "TEL;VALUE=uri;TYPE=work:#{user.phone}" <>
      clrf <>
      "EMAIL;PREF=1;TYPE=home:#{user.email}" <>
      clrf <>
      "EMAIL;TYPE=work:#{user.username}@kth.se" <>
      clrf <>
      "EMAIL;TYPE=work:#{user.google_account}" <>
      clrf <>
      "END:VCARD"
  end

  def preload(users, args \\ []) do
    Repo.preload(users, args)
  end
end
