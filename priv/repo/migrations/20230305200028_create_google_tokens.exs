defmodule Haj.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:google_tokens) do
      add(:refresh_token, :text)
      add(:access_token, :text)
      add(:expire_time, :utc_datetime)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:google_tokens, [:user_id]))
  end
end
