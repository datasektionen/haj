defmodule Haj.Polls.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    belongs_to :poll, Haj.Polls.Poll
    belongs_to :option, Haj.Polls.Option
    belongs_to :user, Haj.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:poll_id, :option_id, :user_id])
    |> validate_required([:poll_id, :option_id, :user_id])
  end
end
