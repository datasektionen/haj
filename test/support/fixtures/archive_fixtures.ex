defmodule Haj.ArchiveFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Archive` context.
  """

  @doc """
  Generate a song.
  """
  def song_fixture(attrs \\ %{}) do
    {:ok, song} =
      attrs
      |> Enum.into(%{
        name: "some name",
        number: 42,
        original_name: "some original_name",
        text: "some text"
      })
      |> Haj.Archive.create_song()

    song
  end
end
