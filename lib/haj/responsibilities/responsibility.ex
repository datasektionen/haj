defmodule Haj.Responsibilities.Responsibility do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responsibilities" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(responsibility, attrs) do
    responsibility
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
