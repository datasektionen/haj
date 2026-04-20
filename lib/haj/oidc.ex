defmodule Haj.OIDC do
  @moduledoc """
  OIDC helpers for discovery and token/userinfo requests.
  """

  @default_scopes "openid profile email"

  def authorize_url!(redirect_uri, state, code_challenge) do
    metadata = discovery!()

    query =
      URI.encode_query(%{
        "client_id" => fetch_env!(:oidc_id),
        "redirect_uri" => redirect_uri,
        "response_type" => "code",
        "scope" => scopes(),
        "state" => state,
        "code_challenge" => code_challenge,
        "code_challenge_method" => "S256"
      })

    metadata["authorization_endpoint"] <> "?" <> query
  end

  def exchange_code!(code, redirect_uri, code_verifier) do
    metadata = discovery!()

    Req.post!(metadata["token_endpoint"],
      form: [
        grant_type: "authorization_code",
        code: code,
        client_id: fetch_env!(:oidc_id),
        client_secret: fetch_env!(:oidc_secret),
        redirect_uri: redirect_uri,
        code_verifier: code_verifier
      ]
    ).body
  end

  def fetch_userinfo!(access_token) do
    metadata = discovery!()

    Req.get!(metadata["userinfo_endpoint"],
      headers: [{"authorization", "Bearer #{access_token}"}]
    ).body
  end

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
