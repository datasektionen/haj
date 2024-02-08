defmodule Haj.Spex.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @group_permissions [:chefsgruppen, :grafiq]

  schema "groups" do
    field :name, :string
    field :description, :string
    field :permission_group, Ecto.Enum, values: @group_permissions

    has_many :show_groups, Haj.Spex.ShowGroup

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :permission_group, :description])
    |> validate_required([:name])
  end

  def group_permissions, do: @group_permissions
end
