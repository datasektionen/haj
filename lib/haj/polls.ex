defmodule Haj.Polls do
  @moduledoc """
  The Polls context.
  """

  import Ecto.Query, warn: false
  alias Haj.Repo

  alias Haj.Polls.Poll
  alias Haj.Polls.Vote
  alias Phoenix.PubSub

  @doc """
  Returns the list of poll.

  ## Examples

      iex> list_polls()
      [%Poll{}, ...]

  """
  def list_polls do
    Repo.all(Poll)
  end

  @doc """
  Gets a single poll.

  Raises `Ecto.NoResultsError` if the Poll does not exist.

  ## Examples

      iex> get_poll!(123)
      %Poll{}

      iex> get_poll!(456)
      ** (Ecto.NoResultsError)

  """
  def get_poll!(id), do: Repo.get!(Poll, id)

  @doc """
  Creates a poll.

  ## Examples

      iex> create_poll(%{field: value})
      {:ok, %Poll{}}

      iex> create_poll(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(attrs \\ %{}) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a poll.

  ## Examples

      iex> update_poll(poll, %{field: new_value})
      {:ok, %Poll{}}

      iex> update_poll(poll, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_poll(%Poll{} = poll, attrs) do
    res =
      poll
      |> Poll.changeset(attrs)
      |> Repo.update()

    broadcast_updated_poll(res)
    res
  end

  @doc """
  Deletes a poll.

  ## Examples

      iex> delete_poll(poll)
      {:ok, %Poll{}}

      iex> delete_poll(poll)
      {:error, %Ecto.Changeset{}}

  """
  def delete_poll(%Poll{} = poll) do
    Repo.delete(poll)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> change_poll(poll)
      %Ecto.Changeset{data: %Poll{}}

  """
  def change_poll(%Poll{} = poll, attrs \\ %{}) do
    Poll.changeset(poll, attrs)
  end

  alias Haj.Polls.Option

  @doc """
  Returns the list of options.

  ## Examples

      iex> list_options()
      [%Option{}, ...]

  """
  def list_options do
    Repo.all(Option)
  end

  @doc """
  Returns the list of options.

  ## Examples

      iex> list_options_for_poll(1)
      [%Option{poll_id: 1}, ...]

  """
  def list_options_for_poll(poll_id) do
    query =
      from o in Option,
        where: o.poll_id == ^poll_id,
        left_join: v in Vote,
        on: v.option_id == o.id,
        group_by: [o.id],
        select: %{o | votes: count(v.id)},
        order_by: [desc: count(v.id), asc: o.name],
        preload: [:creator]

    Repo.all(query)
  end

  @doc """
  Gets a single option.

  Raises `Ecto.NoResultsError` if the Option does not exist.

  ## Examples

      iex> get_option!(123)
      %Option{}

      iex> get_option!(456)
      ** (Ecto.NoResultsError)

  """
  def get_option!(id), do: Repo.get!(Option, id)

  @doc """
  Creates a option.

  ## Examples

      iex> create_option(%{field: value})
      {:ok, %Option{}}

      iex> create_option(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_option(attrs \\ %{}) do
    case %Option{}
         |> Option.changeset(attrs)
         |> Repo.insert() do
      {:ok, option} ->
        option = Repo.preload(option, :creator)
        broadcast_new_option(option)
        {:ok, option}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a option.

  ## Examples

      iex> update_option(option, %{field: new_value})
      {:ok, %Option{}}

      iex> update_option(option, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_option(%Option{} = option, attrs) do
    option
    |> Option.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a option.

  ## Examples

      iex> delete_option(option)
      {:ok, %Option{}}

      iex> delete_option(option)
      {:error, %Ecto.Changeset{}}

  """
  def delete_option(%Option{} = option) do
    Repo.delete(option)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking option changes.

  ## Examples

      iex> change_option(option)
      %Ecto.Changeset{data: %Option{}}

  """
  def change_option(%Option{} = option, attrs \\ %{}) do
    Option.changeset(option, attrs)
  end

  @doc """
  Returns the list of votes.

  ## Examples

      iex> list_votes()
      [%Vote{}, ...]

  """
  def list_votes do
    Repo.all(Vote)
  end

  def list_user_votes_for_poll(poll_id, user_id) do
    query =
      from v in Vote,
        where: v.poll_id == ^poll_id and v.user_id == ^user_id,
        select: v

    Repo.all(query)
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id), do: Repo.get!(Vote, id)

  @doc """
  Creates a vote.

  ## Examples

      iex> create_vote(%{field: value})
      {:ok, %Vote{}}

      iex> create_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(attrs \\ %{}) do
    %Vote{}
    |> Vote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vote.

  ## Examples

      iex> update_vote(vote, %{field: new_value})
      {:ok, %Vote{}}

      iex> update_vote(vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vote(%Vote{} = vote, attrs) do
    vote
    |> Vote.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vote.

  ## Examples

      iex> delete_vote(vote)
      {:ok, %Vote{}}

      iex> delete_vote(vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vote changes.

  ## Examples

      iex> change_vote(vote)
      %Ecto.Changeset{data: %Vote{}}

  """
  def change_vote(%Vote{} = vote, attrs \\ %{}) do
    Vote.changeset(vote, attrs)
  end

  def toggle_user_vote_for_option(option_id, user_id) do
    res =
      Ecto.Multi.new()
      |> Ecto.Multi.one(
        :option,
        from(o in Option,
          where: o.id == ^option_id,
          left_join: v in assoc(o, :votes),
          group_by: [o.id],
          select: %{o | votes: count(v.id)},
          preload: [:creator]
        )
      )
      |> Ecto.Multi.one(
        :prev_vote,
        from(v in Vote, where: v.option_id == ^option_id and v.user_id == ^user_id, select: v)
      )
      |> Ecto.Multi.run(
        :new_vote,
        fn
          repo, %{prev_vote: prev_vote} when not is_nil(prev_vote) ->
            repo.delete(prev_vote)

          repo, %{option: option} ->
            repo.insert(%Vote{option_id: option.id, user_id: user_id, poll_id: option.poll_id})
        end
      )
      |> Ecto.Multi.one(
        :position,
        fn %{option: option} ->
          from(
            ranked in subquery(
              from(o in Option,
                where: o.poll_id == ^option.poll_id,
                left_join: v in assoc(o, :votes),
                group_by: [o.id],
                select: %{
                  id: o.id,
                  rank: dense_rank() |> over(order_by: [desc: count(v.id), asc: o.name])
                }
              )
            ),
            where: ranked.id == ^option.id,
            select: ranked.rank
          )
        end
      )
      |> Repo.transaction()

    broadcast_toggled_vote(res)
    res
  end

  def subscribe(poll_id) do
    PubSub.subscribe(Haj.PubSub, "poll:#{poll_id}")
  end

  defp broadcast_new_option(option) do
    broadcast(option.poll_id, :new_option, %{option: option})
  end

  defp broadcast_toggled_vote(
         {:ok, %{new_vote: new_vote, prev_vote: nil, option: option, position: pos}}
       ) do
    option = %{option | votes: option.votes + 1}
    broadcast(new_vote.poll_id, :new_vote, %{vote: new_vote, option: option, position: pos})
  end

  defp broadcast_toggled_vote({:ok, %{new_vote: deleted, option: option, position: pos}}) do
    option = %{option | votes: option.votes - 1}
    broadcast(deleted.poll_id, :deleted_vote, %{vote: deleted, option: option, position: pos})
  end

  defp broadcast(poll_id, event, payload) do
    PubSub.broadcast(Haj.PubSub, "poll:#{poll_id}", {event, payload})
  end

  defp broadcast_updated_poll({:ok, poll}) do
    PubSub.broadcast(Haj.PubSub, "poll:#{poll.id}", {:poll_updated, %{poll: poll}})
  end

  defp broadcast_updated_poll({:error, _changeset}), do: :ok
end
