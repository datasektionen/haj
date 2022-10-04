defmodule Haj.Foods.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "foods" do
    field :name, :string

    many_to_many :users, Haj.Accounts.User, join_through: "food_preferences"

    timestamps()
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
