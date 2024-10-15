defmodule Haj.ArchiveTest do
  use Haj.DataCase

  alias Haj.Archive

  describe "songs" do
    alias Haj.Archive.Song

    import Haj.ArchiveFixtures

    @invalid_attrs %{name: nil, number: nil, original_name: nil, text: nil}

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Archive.list_songs() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Archive.get_song!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      valid_attrs = %{
        name: "some name",
        number: "1.2",
        original_name: "some original_name",
        text: "some text"
      }

      assert {:ok, %Song{} = song} = Archive.create_song(valid_attrs)
      assert song.name == "some name"
      assert song.number == "1.2"
      assert song.original_name == "some original_name"
      assert song.text == "some text"
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Archive.create_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()

      update_attrs = %{
        name: "some updated name",
        number: "4.3",
        original_name: "some updated original_name",
        text: "some updated text"
      }

      assert {:ok, %Song{} = song} = Archive.update_song(song, update_attrs)
      assert song.name == "some updated name"
      assert song.number == "4.3"
      assert song.original_name == "some updated original_name"
      assert song.text == "some updated text"
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Archive.update_song(song, @invalid_attrs)
      assert song == Archive.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Archive.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Archive.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Archive.change_song(song)
    end
  end
end
