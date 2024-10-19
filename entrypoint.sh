#!/bin/bash

# Only used in development as an entrypoint for the Docker container

set -e

# Ensure the dependencies are installed
mix deps.get

if [[ -f assets/package.json ]]; then
  # Install frontend dependencies with npm
  cd assets
  npm install
  cd ..
fi

echo

# Wait until Postgres is ready
while ! pg_isready -q -h $POSTGRES_HOST -p 5432 -U $POSTGRES_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

export PGPASSWORD=$POSTGRES_PASSWORD

# Create, migrate, and seed database if it doesn't exist.
if psql -lqt -U $POSTGRES_USER -h $POSTGRES_HOST | cut -d \| -f 1 | grep -qw $POSTGRES_DB; then
  echo "Database $POSTGRES_DB exists."
else
  echo "Database $POSTGRES_DB does not exist. Creating..."
  mix ecto.create
  mix ecto.migrate
  mix run priv/repo/seeds.exs
  echo "Database $POSTGRES_DB created."
fi

# Start the Phoenix server
elixir --sname haj -S mix phx.server