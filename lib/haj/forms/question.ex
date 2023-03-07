defmodule Haj.Forms.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "form_questions" do
    field :description, :string
    field :name, :string
    field :required, :boolean, default: false
    field :type, Ecto.Enum, values: [:text, :select, :multi_select]
    field :options, {:array, :string}

    belongs_to :form, Haj.Forms.Form
    has_many :responses, Haj.Forms.Response

    timestamps()
  end

  @doc false
  def changeset(form_question, attrs) do
    form_question
    |> cast(attrs, [:name, :type, :description, :required, :form_id])
    |> validate_required([:name, :type, :description, :required])
  end
end
