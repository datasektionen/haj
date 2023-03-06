defmodule Haj.Forms.Response do
  use Ecto.Schema
  import Ecto.Changeset

  schema "form_responses" do
    field :value, :string

    belongs_to :form, Haj.Forms.Form
    belongs_to :question, Haj.Forms.Question
    belongs_to :user, Haj.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:value, :form_id, :user_id, :question_id])
    |> validate_required([:value])
  end
end
