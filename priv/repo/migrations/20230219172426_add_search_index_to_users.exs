defmodule Haj.Repo.Migrations.AddSearchIndexToUsers do
  use Ecto.Migration

  def up do
    execute("""
      ALTER TABLE users
        ADD COLUMN full_name TEXT
        GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED;
    """)

    execute("""
      CREATE INDEX users_name_gin_trgm_idx ON users USING GIN (full_name gin_trgm_ops);
    """)
  end

  def down do
    execute("""
      DROP INDEX users_name_gin_trgm_idx;
    """)

    execute("""
      ALTER TABLE users DROP COLUMN full_name;
    """)
  end
end
