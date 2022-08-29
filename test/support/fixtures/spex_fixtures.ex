defmodule Haj.SpexFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Spex` context.
  """

  @doc """
  Generate a show.
  """
  def show_fixture(attrs \\ %{}) do
    {:ok, show} =
      attrs
      |> Enum.into(%{
        description: "some description",
        or_title: "some or_title",
        title: "some title",
        year: ~D[2022-06-15]
      })
      |> Haj.Spex.create_show()

    show
  end
end
