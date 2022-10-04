defmodule Haj.Repo.Migrations.CreateFoodPrefrences do
  use Ecto.Migration

  def change do
    create table(:food_preferences) do
      add :food_id, references(:foods)
      add :user_id, references(:users)
    end

    alter table(:users) do
      add :food_preference_other, :text
    end

    create unique_index(:food_preferences, [:food_id, :user_id])
  end
end
