defmodule Haj.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  schema "polls" do
    field :description, :string
    field :title, :string
    field :display_votes, :boolean, default: false
    field :allow_user_options, :boolean, default: false

    has_many :options, Haj.Polls.Option
    has_many :votes, Haj.Polls.Vote

    timestamps()
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:title, :description, :display_votes, :allow_user_options])
    |> validate_required([:title, :description, :display_votes, :allow_user_options])
  end
end
