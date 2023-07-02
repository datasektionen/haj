defmodule Haj.ArchivesTest do
  use Haj.DataCase

  alias Haj.Archives

  describe "song_data" do
    alias Haj.Archives.SongData

    import Haj.ArchivesFixtures

    @invalid_attrs %{file: nil, line_timings: nil}

    test "list_song_data/0 returns all song_data" do
      song_data = song_data_fixture()
      assert Archives.list_song_data() == [song_data]
    end

    test "get_song_data!/1 returns the song_data with given id" do
      song_data = song_data_fixture()
      assert Archives.get_song_data!(song_data.id) == song_data
    end

    test "create_song_data/1 with valid data creates a song_data" do
      valid_attrs = %{file: "some file", line_timings: []}

      assert {:ok, %SongData{} = song_data} = Archives.create_song_data(valid_attrs)
      assert song_data.file == "some file"
      assert song_data.line_timings == []
    end

    test "create_song_data/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Archives.create_song_data(@invalid_attrs)
    end

    test "update_song_data/2 with valid data updates the song_data" do
      song_data = song_data_fixture()
      update_attrs = %{file: "some updated file", line_timings: []}

      assert {:ok, %SongData{} = song_data} = Archives.update_song_data(song_data, update_attrs)
      assert song_data.file == "some updated file"
      assert song_data.line_timings == []
    end

    test "update_song_data/2 with invalid data returns error changeset" do
      song_data = song_data_fixture()
      assert {:error, %Ecto.Changeset{}} = Archives.update_song_data(song_data, @invalid_attrs)
      assert song_data == Archives.get_song_data!(song_data.id)
    end

    test "delete_song_data/1 deletes the song_data" do
      song_data = song_data_fixture()
      assert {:ok, %SongData{}} = Archives.delete_song_data(song_data)
      assert_raise Ecto.NoResultsError, fn -> Archives.get_song_data!(song_data.id) end
    end

    test "change_song_data/1 returns a song_data changeset" do
      song_data = song_data_fixture()
      assert %Ecto.Changeset{} = Archives.change_song_data(song_data)
    end
  end
end
