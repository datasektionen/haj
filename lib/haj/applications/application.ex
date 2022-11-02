defmodule Haj.Applications.Application do
  use Ecto.Schema
  import Ecto.Changeset

  schema "applications" do
    field :other, :string
    field :ranking, :string

    belongs_to :user, Haj.Accounts.User
    belongs_to :show, Haj.Spex.Show
    has_many :application_show_groups, Haj.Applications.ApplicationShowGroup

    timestamps()
  end

  @doc false
  def changeset(application, attrs) do
    application
    |> cast(attrs, [:other, :user_id, :show_id, :ranking])
    |> validate_required([:show_id, :user_id])
  end
end
