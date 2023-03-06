defmodule Haj.GoogleApi do
  import Ecto.Query, warn: false
  alias Haj.Accounts
  alias Phoenix.Token
  alias Haj.Repo

  alias Haj.GoogleApi.Token

  # Credit to https://github.com/coletiv/google_sheets

  @oauth_code_base_uri "https://accounts.google.com/o/oauth2/v2/auth"
  @oauth_token_base_uri "https://oauth2.googleapis.com/"
  @scope "https://www.googleapis.com/auth/drive"
  @drive_api_base_url "https://www.googleapis.com/drive/v3/"

  alias HTTPoison.Response

  def save_token(code, state) do
    url = build_url(:generate_token, code)
    user = Accounts.get_user_by_username!(state)

    with {:ok, %Response{status_code: 200, body: body}} <-
           HTTPoison.post(url, "", [{"Content-Type", "application/x-www-form-urlencoded"}]),
         {:ok, decoded} <- Jason.decode(body) do
      IO.inspect(decoded)

      upsert_token(
        Map.put(decoded, "expire_time", abs_time(decoded["expires_in"]))
        |> Map.put("user_id", user.id)
      )
    end
  end

  def get_acess_token(user_id) do
    access_token = from t in Token, where: t.user_id == ^user_id

    case Repo.one(access_token) do
      nil ->
        {:error,
         %{
           message: "Consent google_sheets app to access google api.",
           url: build_url(:consent_url, Accounts.get_user!(user_id).username)
         }}

      token ->
        if token.expire_time < DateTime.utc_now() do
          refresh_token(token)
        else
          {:ok, "Bearer #{token.access_token}"}
        end
    end
  end

  defp refresh_token(%Token{refresh_token: refresh_token} = token) do
    url = build_url(:refresh_token, refresh_token)

    with {:ok, %Response{status_code: 200, body: body}} <-
           HTTPoison.post(url, "", [{"Content-Type", "application/x-www-form-urlencoded"}]),
         {:ok, decoded} <- Jason.decode(body),
         {:ok, token} <-
           update_token(token, Map.put(decoded, "expire_time", abs_time(decoded["expires_in"]))) do
      {:ok, token}
    else
      _ -> {:error, :request_error}
    end
  end

  defp upsert_token(%{"refresh_token" => refresh_token} = attrs) do
    query = from t in Token, where: t.refresh_token == ^refresh_token

    case Repo.one(query) do
      nil ->
        create_token(attrs) |> IO.inspect()

      existing ->
        existing |> Repo.delete!()
        create_token(attrs)
    end
  end

  defp abs_time(time) do
    DateTime.utc_now() |> DateTime.add(time, :second)
  end

  # Functions to build google api urls for generating consent url and access_tokens
  defp build_url(:generate_token, code),
    do:
      "#{@oauth_token_base_uri}token?code=#{code}&client_id=#{client_id()}&client_secret=#{client_secret()}&redirect_uri=#{redirect_uri()}&grant_type=authorization_code"

  defp build_url(:refresh_token, refresh_token),
    do:
      "#{@oauth_token_base_uri}token?refresh_token=#{refresh_token}&client_id=#{client_id()}&client_secret=#{client_secret()}&grant_type=refresh_token"

  defp build_url(:consent_url, state),
    do:
      "#{@oauth_code_base_uri}?client_id=#{client_id()}&redirect_uri=#{redirect_uri()}&response_type=code&scope=#{@scope}&state=#{state}&access_type=offline"

  # Functions to get environmental variables
  defp client_id(), do: Application.get_env(:haj, :google_client_id)
  defp client_secret(), do: Application.get_env(:haj, :google_client_secret)
  defp redirect_uri(), do: Application.get_env(:haj, :google_redirect_uri)

  alias Haj.GoogleApi.Token

  @doc """
  Returns the list of tokens.

  ## Examples

      iex> list_tokens()
      [%Token{}, ...]

  """
  def list_tokens do
    Repo.all(Token)
  end

  @doc """
  Gets a single token.

  Raises `Ecto.NoResultsError` if the Token does not exist.

  ## Examples

      iex> get_token!(123)
      %Token{}

      iex> get_token!(456)
      ** (Ecto.NoResultsError)

  """
  def get_token!(id), do: Repo.get!(Token, id)

  @doc """
  Creates a token.

  ## Examples

      iex> create_token(%{field: value})
      {:ok, %Token{}}

      iex> create_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_token(attrs \\ %{}) do
    %Token{}
    |> Token.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a token.

  ## Examples

      iex> update_token(token, %{field: new_value})
      {:ok, %Token{}}

      iex> update_token(token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_token(%Token{} = token, attrs) do
    token
    |> Token.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a token.

  ## Examples

      iex> delete_token(token)
      {:ok, %Token{}}

      iex> delete_token(token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_token(%Token{} = token) do
    Repo.delete(token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking token changes.

  ## Examples

      iex> change_token(token)
      %Ecto.Changeset{data: %Token{}}

  """
  def change_token(%Token{} = token, attrs \\ %{}) do
    Token.changeset(token, attrs)
  end

  def upload_file() do
    data = %{
      mimeType: "application/vnd.google-apps.spreadsheet",
      name: "sheet",
      parents: ["11sG5Zv8iJoINd1DngvZ0_utRuFSBvDbW"]
    }

    with {:ok, access_token} <- get_acess_token(1),
         {:ok, %Response{status_code: 200, body: body}} <-
           HTTPoison.post(
             "https://www.googleapis.com/drive/v3/files?supportsAllDrives=true",
             Jason.encode!(data),
             [
               {"Content-Type", "application/json"},
               {"Authorization", "#{access_token}"}
             ]
           ),
         {:ok, decoded} <- Jason.decode(body) do
      decoded
    end
  end
end
