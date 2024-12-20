import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/haj start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :haj, HajWeb.Endpoint, server: true
end

if config_env() == :prod || config_env() == :staging do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :haj, Haj.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  login_api_key = System.get_env("LOGIN_API_KEY") || raise "LOGIN_API_KEY is missing"
  login_url = System.get_env("LOGIN_URL") || raise "LOGIN_URL is missing"

  login_frontend_url =
    System.get_env("LOGIN_FRONTEND_URL") || raise "LOGIN_FRONTEND_URL is missing"

  api_login_secret = System.get_env("API_LOGIN_SECRET") || raise "API_LOGIN_SECRET is missing"
  zfinger_url = System.get_env("ZFINGER_URL") || raise "ZFINGER_URL is missing"
  spam_api_key = System.get_env("SPAM_API_KEY") || raise "SPAM_API_KEY is missing"

  config :haj,
    login_api_key: login_api_key,
    login_url: login_url,
    login_frontend_url: login_frontend_url,
    api_login_secret: api_login_secret,
    zfinger_url: zfinger_url

  # Variables for imgproxy
  imgproxy_key = System.get_env("IMGPROXY_KEY") || raise "IMGPROXY_KEY is missing"
  imgproxy_salt = System.get_env("IMGPROXY_SALT") || raise "IMGPROXY_SALT is missing"
  image_url = System.get_env("IMAGE_URL") || raise "IMAGE_URL is missing"

  config :imgproxy,
    key: imgproxy_key,
    salt: imgproxy_salt,
    prefix: image_url

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :haj, HajWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  ## Configuring the mailer

  config :haj, Haj.Mailer,
    adapter: Haj.Mailer.SpamAdapter,
    api_key: spam_api_key

  config :swoosh, :api_client, Swoosh.ApiClient.Req
end
