defmodule Haj.Repo.Migrations.AddExtaQuestionAndApplicationRanking do
  use Ecto.Migration

  def change do
    alter table(:applications) do
      add :ranking, :text

      remove :special_text
    end

    alter table(:application_show_groups) do
      add :special_text, :text
    end

    alter table(:show_groups) do
      add :application_extra_question, :text
    end
  end
end
