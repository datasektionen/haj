defmodule Haj.Forms.QuestionResponse do
  use Ecto.Schema
  import Ecto.Changeset

  schema "form_question_responses" do
    field :answer, :string
    field :multi_answer, {:array, :string}

    belongs_to :response, Haj.Forms.Response
    belongs_to :question, Haj.Forms.Question

    timestamps()
  end

  @doc false
  def changeset(question_response, attrs) do
    question_response
    |> cast(attrs, [:answer, :multi_answer, :response_id, :question_id])
    |> validate_required([])
  end
end