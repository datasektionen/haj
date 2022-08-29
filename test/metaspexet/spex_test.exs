defmodule Haj.SpexTest do
  use Haj.DataCase

  alias Haj.Spex

  describe "shows" do
    alias Haj.Spex.Show

    import Haj.SpexFixtures

    @invalid_attrs %{description: nil, or_title: nil, title: nil, year: nil}

    test "list_shows/0 returns all shows" do
      show = show_fixture()
      assert Spex.list_shows() == [show]
    end

    test "get_show!/1 returns the show with given id" do
      show = show_fixture()
      assert Spex.get_show!(show.id) == show
    end

    test "create_show/1 with valid data creates a show" do
      valid_attrs = %{description: "some description", or_title: "some or_title", title: "some title", year: ~D[2022-06-15]}

      assert {:ok, %Show{} = show} = Spex.create_show(valid_attrs)
      assert show.description == "some description"
      assert show.or_title == "some or_title"
      assert show.title == "some title"
      assert show.year == ~D[2022-06-15]
    end

    test "create_show/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Spex.create_show(@invalid_attrs)
    end

    test "update_show/2 with valid data updates the show" do
      show = show_fixture()
      update_attrs = %{description: "some updated description", or_title: "some updated or_title", title: "some updated title", year: ~D[2022-06-16]}

      assert {:ok, %Show{} = show} = Spex.update_show(show, update_attrs)
      assert show.description == "some updated description"
      assert show.or_title == "some updated or_title"
      assert show.title == "some updated title"
      assert show.year == ~D[2022-06-16]
    end

    test "update_show/2 with invalid data returns error changeset" do
      show = show_fixture()
      assert {:error, %Ecto.Changeset{}} = Spex.update_show(show, @invalid_attrs)
      assert show == Spex.get_show!(show.id)
    end

    test "delete_show/1 deletes the show" do
      show = show_fixture()
      assert {:ok, %Show{}} = Spex.delete_show(show)
      assert_raise Ecto.NoResultsError, fn -> Spex.get_show!(show.id) end
    end

    test "change_show/1 returns a show changeset" do
      show = show_fixture()
      assert %Ecto.Changeset{} = Spex.change_show(show)
    end
  end
end
