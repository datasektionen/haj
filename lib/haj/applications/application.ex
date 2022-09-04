defmodule Haj.Applications.Application do
  use Ecto.Schema
  import Ecto.Changeset

  schema "applications" do

    field :special_text, :string
    field :other, :string

    belongs_to :user, Haj.Accounts.User
    has_many :application_show_groups, Haj.Applications.ApplicationShowGroup

    timestamps()
  end

  @doc false
  def changeset(application, attrs) do
    application
    |> cast(attrs, [:special_text, :other, :user_id])
    |> validate_required([])
  end
end
