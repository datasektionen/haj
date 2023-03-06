defmodule Haj.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:form_questions) do
      add(:name, :string)
      add(:type, :string)
      add(:description, :text)
      add(:required, :boolean, default: false, null: false)
      add(:form_id, references(:forms, on_delete: :nothing))

      timestamps()
    end

    create(index(:form_questions, [:form_id]))
  end
end
