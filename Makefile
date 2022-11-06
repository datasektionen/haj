mac-install-env:
	brew install elixir
	mix deps.get
	cd assets && npm install
	make start-db
	make populate-db
	make stop-db
	cat ./config/.env.example > ./config/.env
	
populate-db:
	mix ecto.setup

start-db:
	docker run --rm -d -p 5432:5432 -v haj-data:/var/lib/postgresql/data --name=Haj-DB -e POSTGRES_PASSWORD=postgres postgres:12

stop-db:
	docker stop Haj-DB

start-server:
	open "https://localhost.datasektionen.se:4001"
	mix phx.server

start-dev:
	make start-db
	make start-server
