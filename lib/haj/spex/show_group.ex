defmodule Haj.Spex.ShowGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "show_groups" do

    field :application_description, :string
    field :application_extra_question, :string
    field :application_open, :boolean, default: false

    has_many :group_memberships, Haj.Spex.GroupMembership
    belongs_to :group, Haj.Spex.Group
    belongs_to :show, Haj.Spex.Show

    has_many :application_show_groups, Haj.Applications.ApplicationShowGroup

    timestamps()
  end

  @doc false
  def changeset(show_group, attrs) do
    show_group
    |> cast(attrs, [:group_id, :show_id, :application_description, :application_open, :application_extra_question])
    |> validate_required([:group_id, :show_id])
  end
end
