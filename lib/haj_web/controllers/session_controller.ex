defmodule HajWeb.SessionController do
  use HajWeb, :controller
  alias Haj.Accounts
  alias Haj.OIDC
  alias HajWeb.UserAuth

  require Logger

  @doc """
  Starts an OIDC Authorization Code + PKCE login flow.
  """
  def login(conn, %{"return_url" => return_url} = params) do
    conn = put_session(conn, :user_return_to, return_url)
    do_login(conn, params)
  end

  def login(conn, params) do
    do_login(conn, params)
  end

  defp do_login(conn, _params) do
    state = random_token()
    code_verifier = random_token()
    code_challenge = code_challenge(code_verifier)
    redirect_uri = oidc_redirect_uri(conn)

    url = OIDC.authorize_url!(redirect_uri, state, code_challenge)

    conn
    |> put_session(:oidc_state, state)
    |> put_session(:oidc_code_verifier, code_verifier)
    |> redirect(external: url)
  end

  def callback(conn, %{"code" => code, "state" => state}) do
    with :ok <- verify_oidc_state(conn, state),
         code_verifier when is_binary(code_verifier) <- get_session(conn, :oidc_code_verifier),
         token_response <- OIDC.exchange_code!(code, oidc_redirect_uri(conn), code_verifier),
         %{"access_token" => access_token} <- token_response,
         userinfo <- OIDC.fetch_userinfo!(access_token),
         user_attrs <- userinfo_to_user_attrs(userinfo) do
      user = Accounts.upsert_user(user_attrs)

      conn
      |> clear_oidc_session()
      |> UserAuth.log_in_user(user)
    else
      _ ->
        conn
        |> clear_oidc_session()
        |> put_flash(:error, "Inloggningen misslyckades.")
        |> redirect(to: ~p"/login/unauthorized")
    end
  rescue
    error ->
      Logger.error("OIDC callback failed: #{Exception.message(error)}")

      conn
      |> clear_oidc_session()
      |> put_flash(:error, "Inloggningen misslyckades.")
      |> redirect(to: ~p"/login/unauthorized")
  end

  def callback(conn, _params) do
    conn
    |> clear_oidc_session()
    |> put_status(400)
    |> text("400: Missing OIDC callback parameters")
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

  defp verify_oidc_state(conn, state) when is_binary(state) do
    case get_session(conn, :oidc_state) do
      expected when is_binary(expected) and expected == state -> :ok
      _ -> :error
    end
  end

  defp verify_oidc_state(_conn, _state), do: :error

  defp random_token do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end

  defp code_challenge(code_verifier) do
    :sha256
    |> :crypto.hash(code_verifier)
    |> Base.url_encode64(padding: false)
  end

  defp userinfo_to_user_attrs(userinfo) do
    username =
      userinfo["preferred_username"] ||
        userinfo["username"] ||
        username_from_email(userinfo["email"]) ||
        userinfo["sub"]

    email = userinfo["email"] || "#{username}@kth.se"
    {first_name, last_name} = names_from_userinfo(userinfo)

    %{
      "user" => username,
      "emails" => email,
      "first_name" => first_name,
      "last_name" => last_name
    }
  end

  defp names_from_userinfo(%{"given_name" => first_name, "family_name" => last_name})
       when is_binary(first_name) and is_binary(last_name) and first_name != "" and last_name != "" do
    {first_name, last_name}
  end

  defp names_from_userinfo(%{"name" => name}) when is_binary(name) and name != "" do
    case String.split(name, " ", parts: 2, trim: true) do
      [first_name, last_name] -> {first_name, last_name}
      [first_name] -> {first_name, "Okand"}
      _ -> {"Okand", "Okand"}
    end
  end

  defp names_from_userinfo(_userinfo), do: {"Okand", "Okand"}

  defp username_from_email(email) when is_binary(email) do
    case String.split(email, "@", parts: 2) do
      [username, _] when username != "" -> username
      _ -> nil
    end
  end

  defp username_from_email(_), do: nil

  defp clear_oidc_session(conn) do
    conn
    |> delete_session(:oidc_state)
    |> delete_session(:oidc_code_verifier)
  end

  defp oidc_redirect_uri(conn) do
    Application.get_env(:haj, :oidc_redirect_url) || dynamic_redirect_uri(conn)
  end

  defp dynamic_redirect_uri(conn) do
    scheme = forwarded_value(conn, "x-forwarded-proto") || Atom.to_string(conn.scheme)
    forwarded_port = forwarded_value(conn, "x-forwarded-port")
    host = conn.host
    path = Routes.session_path(conn, :callback)

    case build_port(scheme, forwarded_port || Integer.to_string(conn.port)) do
      "" -> "#{scheme}://#{host}#{path}"
      port -> "#{scheme}://#{host}:#{port}#{path}"
    end
  end

  defp forwarded_value(conn, header) do
    case get_req_header(conn, header) do
      [value | _] -> value
      [] -> nil
    end
  end

  defp build_port("https", "443"), do: ""
  defp build_port("http", "80"), do: ""
  defp build_port(_scheme, port), do: port
end
