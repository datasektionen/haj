defmodule Haj.Spex.ShowGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "show_groups" do

    has_many :group_memberships, Haj.Spex.GroupMembership
    belongs_to :group, Haj.Spex.Group
    belongs_to :show, Haj.Spex.Show

    timestamps()
  end

  @doc false
  def changeset(show_group, attrs) do
    show_group
    |> cast(attrs, [:group_id, :show_id])
    |> validate_required([:group_id, :show_id])
  end
end
