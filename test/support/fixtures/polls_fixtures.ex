defmodule Haj.PollsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Polls` context.
  """

  @doc """
  Generate a poll.
  """
  def poll_fixture(attrs \\ %{}) do
    {:ok, poll} =
      attrs
      |> Enum.into(%{
        allow_user_options: true,
        description: "some description",
        display_votes: true,
        title: "some title"
      })
      |> Haj.Polls.create_poll()

    poll
  end

  @doc """
  Generate a option.
  """
  def option_fixture(attrs \\ %{}) do
    {:ok, option} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        url: "some url"
      })
      |> Haj.Polls.create_option()

    option
  end

  @doc """
  Generate a vote.
  """
  def vote_fixture(attrs \\ %{}) do
    {:ok, vote} =
      attrs
      |> Enum.into(%{})
      |> Haj.Polls.create_vote()

    vote
  end
end
