# Haj

Public website of [metaspexet.se](https://metaspexet.se) and internal site [haj.metaspexet.se](haj.metaspexet.se). Still very much work in progress!
### How to run

Prerequisites:

  * You will need an env variables `LOGIN_API_KEY`, and `LOGIN_HOST` set. You need to obtain an api key to `login` (https://login.datasektionen.se).
  * In order to run on local machine, you will need to alias DNS records between `localhost.datasektionen.se` and `datasektionen.se` to localhost.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost.datasektionen.se:4001`](http://localhost.datasektionen.se:4001) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
