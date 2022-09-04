defmodule Haj.Spex.GroupMembership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_memberships" do
    field :role, Ecto.Enum, values: [:chef, :gruppis]

    belongs_to :user, Haj.Accounts.User
    belongs_to :show_group, Haj.Spex.ShowGroup

    timestamps()
  end

  @doc false
  def changeset(group_membership, attrs) do
    group_membership
    |> cast(attrs, [:user_id, :show_group_id, :role])
    |> validate_required([:role])
  end
end
