defmodule Haj.Forms.Response do
  use Ecto.Schema
  import Ecto.Changeset

  schema "form_responses" do
    belongs_to :form, Haj.Forms.Form
    belongs_to :user, Haj.Accounts.User

    has_many :question_responses, Haj.Forms.QuestionResponse

    timestamps()
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:form_id, :user_id, :question_id])
    |> validate_required([])
  end
end
