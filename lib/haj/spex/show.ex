defmodule Haj.Spex.Show do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shows" do
    field :description, :string
    field :or_title, :string
    field :title, :string
    field :year, :date

    timestamps()
  end

  @doc false
  def changeset(show, attrs) do
    show
    |> cast(attrs, [:title, :or_title, :year, :description])
    |> validate_required([:title, :or_title, :year, :description])
  end
end
