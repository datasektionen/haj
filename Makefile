# Fonts & colors
BOLD         := $(shell tput bold)
UNDERLINE    := $(shell tput smul)

BLACK        := $(shell tput -Txterm setaf 0)
RED          := $(shell tput -Txterm setaf 1)
GREEN        := $(shell tput -Txterm setaf 2)
YELLOW       := $(shell tput -Txterm setaf 3)
BLUE         := $(shell tput -Txterm setaf 4)
MAGENTA      := $(shell tput -Txterm setaf 5)
CYAN         := $(shell tput -Txterm setaf 6)
WHITE        := $(shell tput -Txterm setaf 7)

.PHONY: mac-install-env
mac-install-env:
	brew install elixir
	mix deps.get
	@cd assets && npm install
	@make start-db
	@make populate-db
	@make stop-db
	@cat ./config/.env.example > ./config/.env
	@echo ""
	@echo "Success! Now you can run 'make start-server' to start the server."
	@echo ""

.PHONY: populate-db
populate-db:
	mix ecto.setup

# Starts db if one exists, otherwise creates a new db
# (workaround since closing the server doesn't stop the db)
.PHONY: start-db
start-db:
	@docker start Haj-DB 2>/dev/null || \
	docker run --rm -d -p 5432:5432 -v haj-data:/var/lib/postgresql/data --name=Haj-DB -e POSTGRES_PASSWORD=postgres postgres:12 && \
	echo "${BOLD} ${GREEN}" && \
	echo "Successfully started Haj-DB!" && \
	echo ""

.PHONY: stop-db
stop-db:
	docker stop Haj-DB

.PHONY: start-server
start-server:
	@echo "${CYAN}Starting server @ https://localhost.datasektionen.se:4001...${WHITE}"
	@echo ""
	@mix phx.server

.PHONY: start-dev
start-dev:
	@make start-db
	@make start-server
