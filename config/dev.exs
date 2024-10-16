import Config

# Configure your database
config :haj, Haj.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: System.get_env("POSTGRES_DB", "haj_dev"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :haj,
  login_api_key: System.get_env("LOGIN_API_KEY"),
  login_url: System.get_env("LOGIN_URL"),
  spam_api_key: System.get_env("SPAM_API_KEY"),
  login_frontend_url: System.get_env("LOGIN_FRONTEND_URL", "http://localhost:7002"),
  port: 4001,
  api_login_secret: "usemetologin",
  zfinger_url: System.get_env("ZFINGER_URL")

config :imgproxy,
  key: System.get_env("IMGPROXY_KEY"),
  salt: System.get_env("IMGPROXY_SALT"),
  prefix: System.get_env("IMAGE_URL")

if System.get_env("AWS_LOCAL") != "false" do
  config :ex_aws, :s3,
    scheme: System.get_env("AWS_S3_SCHEME", "http://"),
    host: System.get_env("AWS_S3_HOST", "localhost"),
    port: System.get_env("AWS_S3_PORT", "9000")
end

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :haj, HajWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {0, 0, 0, 0}, port: 4000],
  https: [
    port: 4001,
    cipher_suite: :strong,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "RUHbVZPF+d8pFNH0XkAuD8qsDWYgD2j/RW4FMi9OfM6tAad1gJrZAQAmEXovDEVl",
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :haj, HajWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/haj_web/(live|views)/.*(ex)$",
      ~r"lib/haj_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
