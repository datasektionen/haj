defmodule Haj.Applications.Application do
  use Ecto.Schema
  import Ecto.Changeset

  schema "applications" do
    field :other, :string
    field :ranking, :string

    field :group_ids, {:array, :integer}, virtual: true

    field :status, Ecto.Enum,
      values: [:pending, :submitted],
      default: :pending

    belongs_to :user, Haj.Accounts.User
    belongs_to :show, Haj.Spex.Show
    has_many :application_show_groups, Haj.Applications.ApplicationShowGroup

    timestamps()
  end

  @doc false
  def changeset(application, attrs) do
    application
    |> cast(attrs, [:other, :user_id, :show_id, :ranking, :status])
    |> validate_required([:show_id, :user_id])
  end

  @doc false
  def changeset_with_show_groups(application, attrs) do
    application
    |> cast(attrs, [:other, :ranking, :group_ids])
    |> validate_required([:group_ids])
  end
end
