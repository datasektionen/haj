defmodule Haj.Repo.Migrations.FormOnDelete do
  use Ecto.Migration

  def change do
    alter table(:form_questions) do
      modify :form_id, references(:forms, on_delete: :delete_all),
        from: references(:forms, on_delete: :nothing)
    end

    alter table(:form_responses) do
      modify :form_id, references(:forms, on_delete: :delete_all),
        from: references(:forms, on_delete: :nothing)
    end

    alter table(:form_question_responses) do
      modify :question_id, references(:form_questions, on_delete: :nilify_all),
        from: references(:form_questions, on_delete: :nothing)

      modify :response_id, references(:form_responses, on_delete: :nilify_all),
        from: references(:form_responses, on_delete: :nothing)
    end
  end
end
