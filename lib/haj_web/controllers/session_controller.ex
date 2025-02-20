defmodule HajWeb.SessionController do
  use HajWeb, :controller
  alias Haj.Accounts
  alias HajWeb.UserAuth

  require Logger

  @doc """
  Issues a request to the login server, by redirecting the user there
  """
  def login(conn, %{"return_url" => return_url} = params) do
    conn = put_session(conn, :user_return_to, return_url)
    do_login(conn, params)
  end

  def login(conn, params) do
    do_login(conn, params)
  end

  defp do_login(conn, _params) do
    login_frontend_url = Application.get_env(:haj, :login_frontend_url)

    scheme =
      case get_req_header(conn, "x-forwarded-proto") do
        [scheme] -> scheme
        [] -> conn.scheme
      end

    port =
      case get_req_header(conn, "x-forwarded-port") do
        [port] -> port
        [] -> conn.port
      end

    callback = URI.encode("#{scheme}://#{conn.host}:#{port}/login/callback/?token=")
    url = "#{login_frontend_url}/login?callback=#{callback}"

    conn
    |> put_resp_header("location", url)
    |> send_resp(302, "")
  end

  def callback(conn, %{"token" => token}) do
    login_url = Application.get_env(:haj, :login_url)
    api_key = Application.get_env(:haj, :login_api_key)

    response = Req.get!("#{login_url}/verify/#{token}.json?api_key=#{api_key}")

  case response do
    %{status: 200, body: data} ->
      user = Accounts.upsert_user(data)

      # Get the path first before logging in
      redirect_to =
        case Haj.Applications.get_current_application_for_user(user.id) do
          nil -> UserAuth.signed_in_path(conn)
          %{id: id} -> ~p"/applications/#{id}/edit"
        end

      # Log in with explicit redirect path
      conn
      |> put_session(:user_return_to, redirect_to)
      |> UserAuth.log_in_user(user)

    _ ->
      conn |> put_status(503) |> text("503: Something went wrong")
  end
  end

  defp handle_post_login_redirect(conn, user) do
    case Haj.Applications.get_pending_application_for_user(user.id) do
      nil ->
        conn  # No pending application, proceed normally

      %{id: application_id} ->
        conn
        |> redirect(to: ~p"/applications/#{application_id}/edit")
        |> halt()
    end
  end

  def login_api(conn, %{"key" => key, "kth-id" => username}) do
    secret = Application.get_env(:haj, :api_login_secret)

    Logger.info("User #{username} is trying to log in via API")

    case key == secret do
      true ->
        user = Accounts.get_user_by_username!(username)

        Logger.info("User #{username} logged in via API")
        UserAuth.log_in_user(conn, user)

      _ ->
        conn |> put_status(401) |> text("401: Unauthorized")
    end
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "Logged out!")
    |> UserAuth.log_out_user()
  end
end
