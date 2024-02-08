defmodule Haj.Responsibilities.ResponsibleUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responsibility_users" do
    belongs_to :show, Haj.Spex.Show
    belongs_to :user, Haj.Accounts.User
    belongs_to :responsibility, Haj.Responsibilities.Responsibility

    timestamps()
  end

  @doc false
  def changeset(responsible_user, attrs) do
    responsible_user
    |> cast(attrs, [:show_id, :user_id, :responsibility_id])
    |> validate_required([])
  end
end
