defmodule Haj.GoogleApi.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "google_tokens" do
    field :access_token, :string
    field :expire_time, :utc_datetime
    field :refresh_token, :string

    belongs_to :user, Haj.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:refresh_token, :access_token, :expire_time, :user_id])
    |> validate_required([:access_token, :expire_time, :refresh_token, :user_id])
  end
end
