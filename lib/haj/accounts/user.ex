defmodule Haj.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :username, :string

    field :google_account, :string
    field :phone, :string
    field :class, :string
    field :personal_number, :string

    field :role, Ecto.Enum, values: [:admin, :chef, :spexare, :none], default: :none

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :username, :google_account, :phone, :class, :personal_number])
    |> validate_required([:first_name, :last_name, :email, :username])
  end
end
