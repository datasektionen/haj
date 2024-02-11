defmodule Haj.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :username, :string
    field :full_name, :string

    field :google_account, :string
    field :phone, :string
    field :class, :string
    field :personal_number, :string

    field :street, :string
    field :zip, :string
    field :city, :string

    field :role, Ecto.Enum, values: [:admin, :chef, :spexare, :none], default: :none

    many_to_many :foods, Haj.Foods.Food, join_through: "food_preferences", on_replace: :delete
    has_many :group_memberships, Haj.Spex.GroupMembership

    field :food_preference_other, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [
      :first_name,
      :last_name,
      :email,
      :username,
      :google_account,
      :phone,
      :class,
      :personal_number,
      :street,
      :zip,
      :city,
      :role,
      :food_preference_other
    ])
    |> validate_format(:personal_number, ~r"^\d{10}$",
      message: "Personnummer måste vara 10 siffror, utan bindestreck."
    )
    # |> validate_format(:class, ~r"^(D|Media)-\d{2}$", message: "Klass måste vara på formen D-20 eller Media-09")
    |> validate_format(:zip, ~r"^(\d{5}|\d{3}\s\d{2})$", message: "Postkod måste vara 5 siffror.")
    |> validate_required([:first_name, :last_name, :email, :username],
      message: "Får ej vara tomt."
    )
  end

  @doc false
  def application_changeset(user, attrs \\ %{}) do
    changeset(user, attrs)
    |> validate_required([:class, :phone], message: "Får ej vara tomt.")
    |> validate_change(:username, fn :username, _ ->
      [username: "Du kan inte ändra KTH-id!"]
    end)
  end
end

defimpl Phoenix.HTML.Safe, for: Haj.Accounts.User do
  def to_iodata(user) do
    Phoenix.HTML.Engine.html_escape(user.full_name)
  end
end
