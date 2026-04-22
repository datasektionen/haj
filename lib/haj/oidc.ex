defmodule Haj.OIDC do
  @moduledoc """
  OIDC helpers for discovery and token/userinfo requests.
  """

  @default_scopes "openid profile email"

  def authorize_url!(redirect_uri, state) do
    metadata = discovery!()

    query =
      URI.encode_query(%{
        "client_id" => fetch_env!(:oidc_id),
        "redirect_uri" => redirect_uri,
        "response_type" => "code",
        "scope" => scopes(),
        "state" => state
      })

    metadata["authorization_endpoint"] <> "?" <> query
  end

  def exchange_code!(code, redirect_uri) do
    metadata = discovery!()
    client_id = fetch_env!(:oidc_id)
    client_secret = fetch_env!(:oidc_secret)
    basic = Base.encode64("#{client_id}:#{client_secret}")

    form = [
      grant_type: "authorization_code",
      code: code,
      redirect_uri: redirect_uri
    ]

    case Req.post(metadata["token_endpoint"],
           headers: [{"authorization", "Basic #{basic}"}],
           form: form
         ) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body}} when status in [400, 401] ->
        # Some clients are configured as public and require no client authentication.
        case Req.post(metadata["token_endpoint"], form: [client_id: client_id] ++ form) do
          {:ok, %{status: fallback_status, body: fallback_body}}
          when fallback_status in 200..299 ->
            {:ok, fallback_body}

          {:ok, %{status: fallback_status, body: fallback_body}} ->
            {:error, {:token_exchange_failed, fallback_status, fallback_body, status, body}}

          {:error, reason} ->
            {:error, {:token_exchange_error, reason, status, body}}
        end

      {:ok, %{status: status, body: body}} ->
        {:error, {:token_exchange_failed, status, body}}

      {:error, reason} ->
        {:error, {:token_exchange_error, reason}}
    end
  end

  def fetch_userinfo!(access_token) do
    metadata = discovery!()

    case Req.get(metadata["userinfo_endpoint"],
           headers: [{"authorization", "Bearer #{access_token}"}]
         ) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, {:userinfo_failed, status, body}}

      {:error, reason} ->
        {:error, {:userinfo_error, reason}}
    end
  end

  def subject_from_id_token(%{"id_token" => id_token}) when is_binary(id_token) do
    with [_header, payload, _signature] <- String.split(id_token, "."),
         {:ok, decoded_payload} <- Base.url_decode64(payload, padding: false),
         {:ok, claims} <- Jason.decode(decoded_payload),
         sub when is_binary(sub) and sub != "" <- claims["sub"] do
      {:ok, sub}
    else
      _ -> {:error, :missing_subject_claim}
    end
  end

  def subject_from_id_token(_), do: {:error, :missing_id_token}

  defp discovery! do
    provider = fetch_env!(:oidc_provider) |> String.trim_trailing("/")
    url = provider <> "/.well-known/openid-configuration"

    Req.get!(url).body
  end

  defp scopes do
    Application.get_env(:haj, :oidc_scopes, @default_scopes)
  end

  defp fetch_env!(key) do
    Application.fetch_env!(:haj, key)
  end
end
