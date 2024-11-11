defmodule Haj.PollsTest do
  use Haj.DataCase

  alias Haj.Polls

  describe "poll" do
    alias Haj.Polls.Poll

    import Haj.PollsFixtures

    @invalid_attrs %{description: nil, title: nil, display_votes: nil, allow_user_options: nil}

    test "list_polls/0 returns all poll" do
      poll = poll_fixture()
      assert Polls.list_polls() == [poll]
    end

    test "get_poll!/1 returns the poll with given id" do
      poll = poll_fixture()
      assert Polls.get_poll!(poll.id) == poll
    end

    test "create_poll/1 with valid data creates a poll" do
      valid_attrs = %{
        description: "some description",
        title: "some title",
        display_votes: true,
        allow_user_options: true
      }

      assert {:ok, %Poll{} = poll} = Polls.create_poll(valid_attrs)
      assert poll.description == "some description"
      assert poll.title == "some title"
      assert poll.display_votes == true
      assert poll.allow_user_options == true
    end

    test "create_poll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_poll(@invalid_attrs)
    end

    test "update_poll/2 with valid data updates the poll" do
      poll = poll_fixture()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        display_votes: false,
        allow_user_options: false
      }

      assert {:ok, %Poll{} = poll} = Polls.update_poll(poll, update_attrs)
      assert poll.description == "some updated description"
      assert poll.title == "some updated title"
      assert poll.display_votes == false
      assert poll.allow_user_options == false
    end

    test "update_poll/2 with invalid data returns error changeset" do
      poll = poll_fixture()
      assert {:error, %Ecto.Changeset{}} = Polls.update_poll(poll, @invalid_attrs)
      assert poll == Polls.get_poll!(poll.id)
    end

    test "delete_poll/1 deletes the poll" do
      poll = poll_fixture()
      assert {:ok, %Poll{}} = Polls.delete_poll(poll)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_poll!(poll.id) end
    end

    test "change_poll/1 returns a poll changeset" do
      poll = poll_fixture()
      assert %Ecto.Changeset{} = Polls.change_poll(poll)
    end
  end

  describe "options" do
    alias Haj.Polls.Option

    import Haj.PollsFixtures

    @invalid_attrs %{name: nil, description: nil, url: nil}

    test "list_options/0 returns all options" do
      option = option_fixture()
      assert Polls.list_options() == [option]
    end

    test "get_option!/1 returns the option with given id" do
      option = option_fixture()
      assert Polls.get_option!(option.id) == option
    end

    test "create_option/1 with valid data creates a option" do
      valid_attrs = %{name: "some name", description: "some description", url: "some url"}

      assert {:ok, %Option{} = option} = Polls.create_option(valid_attrs)
      assert option.name == "some name"
      assert option.description == "some description"
      assert option.url == "some url"
    end

    test "create_option/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_option(@invalid_attrs)
    end

    test "update_option/2 with valid data updates the option" do
      option = option_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        url: "some updated url"
      }

      assert {:ok, %Option{} = option} = Polls.update_option(option, update_attrs)
      assert option.name == "some updated name"
      assert option.description == "some updated description"
      assert option.url == "some updated url"
    end

    test "update_option/2 with invalid data returns error changeset" do
      option = option_fixture()
      assert {:error, %Ecto.Changeset{}} = Polls.update_option(option, @invalid_attrs)
      assert option == Polls.get_option!(option.id)
    end

    test "delete_option/1 deletes the option" do
      option = option_fixture()
      assert {:ok, %Option{}} = Polls.delete_option(option)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_option!(option.id) end
    end

    test "change_option/1 returns a option changeset" do
      option = option_fixture()
      assert %Ecto.Changeset{} = Polls.change_option(option)
    end
  end

  describe "votes" do
    alias Haj.Polls.Vote

    import Haj.PollsFixtures

    @invalid_attrs %{}

    test "list_votes/0 returns all votes" do
      vote = vote_fixture()
      assert Polls.list_votes() == [vote]
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = vote_fixture()
      assert Polls.get_vote!(vote.id) == vote
    end

    test "create_vote/1 with valid data creates a vote" do
      valid_attrs = %{}

      assert {:ok, %Vote{} = vote} = Polls.create_vote(valid_attrs)
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_vote(@invalid_attrs)
    end

    test "update_vote/2 with valid data updates the vote" do
      vote = vote_fixture()
      update_attrs = %{}

      assert {:ok, %Vote{} = vote} = Polls.update_vote(vote, update_attrs)
    end

    test "update_vote/2 with invalid data returns error changeset" do
      vote = vote_fixture()
      assert {:error, %Ecto.Changeset{}} = Polls.update_vote(vote, @invalid_attrs)
      assert vote == Polls.get_vote!(vote.id)
    end

    test "delete_vote/1 deletes the vote" do
      vote = vote_fixture()
      assert {:ok, %Vote{}} = Polls.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = vote_fixture()
      assert %Ecto.Changeset{} = Polls.change_vote(vote)
    end
  end
end
