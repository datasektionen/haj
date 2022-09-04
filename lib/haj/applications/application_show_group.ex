defmodule Haj.Applications.ApplicationShowGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "application_show_groups" do

    belongs_to :application, Haj.Applications.Application
    belongs_to :show_group, Haj.Spex.ShowGroup

    timestamps()
  end

  @doc false
  def changeset(application, attrs) do
    application
    |> cast(attrs, [:application_id, :show_group_id])
    |> validate_required([])
  end
end
