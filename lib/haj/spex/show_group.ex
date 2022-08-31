defmodule Haj.Spex.ShowGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "show_groups" do

    field :show_id, :id
    field :group_id, :id

    timestamps()
  end

  @doc false
  def changeset(show_group, attrs) do
    show_group
    |> cast(attrs, [])
    |> validate_required([])
  end
end
