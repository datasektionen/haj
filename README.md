# Haj

Public website of [metaspexet.se](https://metaspexet.se) and internal site [haj.metaspexet.se](https://haj.metaspexet.se). Still very much work in progress!
### How to run

Prerequisites:

  * You will need an env variables `LOGIN_API_KEY`, and `LOGIN_HOST` set. You need to obtain an api key to `login` (https://login.datasektionen.se).
  * In order to run on local machine, you will need to alias DNS records between `localhost.datasektionen.se` and `datasektionen.se` to localhost.

To start your Phoenix server:

#### Mac

  This process requires docker, if you don't have it you can either install it [here](https://www.docker.com/products/docker-desktop/) or follow the general instructions below. 
  If you already have a normal postgres installation on your computer, use the general instructions below.

  1. Setup environment with ```make mac-install-env```
  2. Set correct data in the .env file in config/.env
  3. Run ```make start-dev```, this should open up the website (you will have to reload it the first time)

When you have your docker database running, you can use `mix phx.server` to start the server.

#### Windows and general instructions

  1. Install dependencies with `mix deps.get`
  2. Install npm dependencies with `cd assets && npm install && cd ..`
  3. Create and migrate your database with `mix ecto.setup`
  4. Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost.datasektionen.se:4001`](http://localhost.datasektionen.se:4001) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
