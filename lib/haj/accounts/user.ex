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
    |> validate_format(:personal_number, ~r"^\d{10}$", message: "Personnummer måste vara 10 siffror")
    |> validate_format(:class, ~r"^(D|Media)-\d{2}$", message: "Klass måste vara på formen D-20 eller Media-09")
    |> validate_required([:first_name, :last_name, :email, :username])
  end
end
