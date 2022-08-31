defmodule Haj.Spex.GroupMembership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_memberships" do
    field :role, Ecto.Enum, values: [:chef, :gruppis]
    field :user_id, :id
    field :show_id, :id
    field :group_id, :id

    timestamps()
  end

  @doc false
  def changeset(group_membership, attrs) do
    group_membership
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end
end
