defmodule Haj.Responsibilities.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responsibility_comments" do
    field :text, :string
    field :show_id, :id
    field :user_id, :id
    field :responsibility_id, :id

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
