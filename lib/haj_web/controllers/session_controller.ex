defmodule HajWeb.SessionController do
  use HajWeb, :controller
  alias Haj.Accounts
  alias HajWeb.UserAuth

  require Logger

  @doc """
  Issues a request to the login server, by redirecting the user there
  """
  def login(conn, _params) do
    Logger.info("logging in")
    host = Application.get_env(:haj, :login_host)

    scheme = case get_req_header(conn, "x-forwarded-proto") do
      [scheme] -> scheme
      [] -> conn.scheme
    end

    port = case get_req_header(conn, "x-forwarded-port") do
      [port] -> port
      [] -> conn.port
    end

    callback = URI.encode("#{scheme}://#{conn.host}:#{port}/login/callback/?token=")
    url = "https://#{host}/login?callback=#{callback}"

    conn
    |> put_resp_header("location", url)
    |> send_resp(302, "")
  end

  def callback(conn, %{"token" => token}) do
    # Gets the users data from the login server
    host = Application.get_env(:haj, :login_host)
    api_key = Application.get_env(:haj, :login_api_key)

    {:ok, response} = HTTPoison.get("https://#{host}/verify/#{token}.json?api_key=#{api_key}")

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
