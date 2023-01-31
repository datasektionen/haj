defmodule Haj.ResponsibilitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Haj.Responsibilities` context.
  """

  @doc """
  Generate a responsibility.
  """
  def responsibility_fixture(attrs \\ %{}) do
    {:ok, responsibility} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Haj.Responsibilities.create_responsibility()

    responsibility
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        text: "some text"
      })
      |> Haj.Responsibilities.create_comment()

    comment
  end
end
