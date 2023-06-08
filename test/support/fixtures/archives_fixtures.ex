defmodule Haj.ArchivesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Archives` context.
  """

  @doc """
  Generate a song_data.
  """
  def song_data_fixture(attrs \\ %{}) do
    {:ok, song_data} =
      attrs
      |> Enum.into(%{
        file: "some file",
        line_timings: []
      })
      |> Haj.Archives.create_song_data()

    song_data
  end
end
