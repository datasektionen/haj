defmodule Haj.Forms.Form do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forms" do
    field :description, :string
    field :name, :string

    has_many :questions, Haj.Forms.Question
    has_many :responses, Haj.Forms.Response

    timestamps()
  end

  @doc false
  def changeset(form, attrs) do
    form
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
