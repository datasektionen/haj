defmodule Haj.Applications.Application do
  use Ecto.Schema
  import Ecto.Changeset

  schema "applications" do

    field :user_id, :id
    field :group_id, :id

    timestamps()
  end

  @doc false
  def changeset(application, attrs) do
    application
    |> cast(attrs, [])
    |> validate_required([])
  end
end
