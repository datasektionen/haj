defmodule HajWeb.SessionController do
  use HajWeb, :controller
  alias Haj.Accounts
  alias HajWeb.UserAuth

  @host Application.get_env(:haj, :login_host)
  @api_key Application.get_env(:haj, :login_api_key)

  @doc """
  Issues a request to the login server, by redirecting the user there
  """
  def login(conn, _params) do
    callback = URI.encode("#{conn.scheme}://#{conn.host}:#{conn.port}/login/callback/?token=")
    url = "https://#{@host}/login?callback=#{callback}"

    conn
    |> put_resp_header("location", url)
    |> send_resp(302, "")
  end

  def callback(conn, %{"token" => token}) do
    # Gets the users data from the login server
    {:ok, response} = HTTPoison.get("https://#{@host}/verify/#{token}.json?api_key=#{@api_key}")

    case response do
      %{status_code: 200, body: data} ->
        # Get the user or insert into database
        user = Accounts.upsert_user(Jason.decode!(data))
        UserAuth.log_in_user(conn, user)

      _ ->
        conn |> put_status(503) |> text("503: Something went wrong")
    end
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "Logged out!")
    |> UserAuth.log_out_user()
  end
end
