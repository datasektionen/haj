defmodule Haj.Polls.Option do
  use Ecto.Schema
  import Ecto.Changeset

  schema "options" do
    field :name, :string
    field :description, :string
    field :url, :string

    has_many :votes, Haj.Polls.Vote
    belongs_to :poll, Haj.Polls.Poll
    belongs_to :creator, Haj.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:name, :description, :url, :poll_id, :creator_id])
    |> validate_required([:name, :description, :url])
  end
end
