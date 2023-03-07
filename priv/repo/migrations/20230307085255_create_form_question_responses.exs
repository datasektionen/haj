defmodule Haj.Repo.Migrations.CreateFormQuestionResponses do
  use Ecto.Migration

  def change do
    create table(:form_question_responses) do
      add :answer, :text
      add :multi_answer, {:array, :string}
      add :response_id, references(:form_responses, on_delete: :nothing)
      add :question_id, references(:form_questions, on_delete: :nothing)

      timestamps()
    end

    create index(:form_question_responses, [:response_id])
    create index(:form_question_responses, [:question_id])
  end
end
