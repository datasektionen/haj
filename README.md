# Haj

Public website of [metaspexet.se](https://metaspexet.se) and internal site [haj.metaspexet.se](https://haj.metaspexet.se). Still very much work in progress!

## Development

### Using Docker

A full development environment can be started using docker-compose. This will start a seeded postgres database,
a mock login server, a Minio server for file storage, a local imgproxy server and the main Phoenix server.

```bash
docker-compose up
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Using local environment

This is considerably more complex, and requires a bit of setup. You will also need access to many environment variables. This is not recommended.

Prerequisites:

- You will need an env variables as defined in `config/.env.example` file. Most notably, you will need
  a `LOGIN_API_KEY` to be able to login. If you wish to interact with media files (images, audio) you will
  need either an S3 bucket or a Minio server running locally. See the `docker-compose.yml` file for an example
  of how to run a Minio server locally.
- Our images are served by an [imgproxy](https://github.com/imgproxy/imgproxy) server behind a Cloudfront CDN. You will need to use correct `IMGPROXY_KEY` and `IMGPROXY_SALT` env variables set. You can also run a local imgproxy server by running `docker-compose up imgproxy`.

To start your Phoenix server:

#### Mac

This process requires docker, if you don't have it you can either install it [here](https://www.docker.com/products/docker-desktop/) or follow the general instructions below.
If you already have a normal postgres installation on your computer, use the general instructions below.

1. Setup environment with `make mac-install-env`
2. Set correct data in the .env file in config/.env
3. Run `make start-dev`, this should open up the website (you will have to reload it the first time)

When you have your docker database running, you can use `mix phx.server` to start the server.

#### Windows and general instructions

1. Install dependencies with `mix deps.get`
2. Install npm dependencies with `cd assets && npm install && cd ..`
3. Create and migrate your database with `mix ecto.setup`
4. Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
